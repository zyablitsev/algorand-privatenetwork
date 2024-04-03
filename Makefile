# load config parameters
ifneq (,$(wildcard ./config))
	include config
endif

v_bin_dir=$(or ${BIN_DIR},${bin_dir})
v_tmp_dir=$(or ${TMP_DIR},${tmp_dir})
v_data_dir=$(or ${DATA_DIR},${data_dir})
v_conduit_data_dir=$(or ${CONDUIT_DATA_DIR},${conduit_data_dir})
v_update_script_uri=$(or ${UPDATE_SCRIPT_URI},${update_script_uri})
v_algod_net=$(or ${ALGOD_NET},${algod_net})
v_algod_token=$(or ${ALGOD_TOKEN},${algod_token})
v_algod_admin_token=$(or ${ALGOD_ADMIN_TOKEN},${algod_admin_token})
v_kmd_token=$(or ${KMD_TOKEN},${kmd_token})

v_pg_host=$(or ${PG_HOST},${pg_host})
v_pg_port=$(or ${PG_PORT},${pg_port})
v_pg_user=$(or ${PG_USERNAME},${pg_user})
v_pg_pass=$(or ${PG_PASSWORD},${pg_pass})
v_pg_dbuser=$(or ${PG_DBUSER},${pg_dbuser})
v_pg_dbpass=$(or ${PG_DBPASSWORD},${pg_dbpass})
v_pg_dbname=$(or ${PG_DBNAME},${pg_dbname})
v_pg_dbschema=$(or ${PG_DBSCHEMA},${pg_dbschema})

binaries-download: binaries-clean
	mkdir -p ${v_tmp_dir}/
	curl \
		"${v_update_script_uri}" \
		-o ${v_tmp_dir}/update.sh
	chmod 500 ${v_tmp_dir}/update.sh
	mkdir -p ${v_bin_dir}/
	cd ${v_tmp_dir}/ \
		&& ./update.sh -i -n -c stable \
		-p ../${v_bin_dir}/ \
		-d ../${v_data_dir}
	./download-indexer.sh
	./download-conduit.sh

binaries-clean:
	rm -rf ${v_tmp_dir}/ 2>/dev/null || true
	rm -rf ${v_bin_dir}/ 2>/dev/null || true

network-create: network-stop network-delete
	${v_bin_dir}/goal network create \
		-r ${v_data_dir}/privatenetwork/ \
		-n sandnet \
		-t ./template.${v_algod_net}.json
	cp node-config.json ${v_data_dir}/privatenetwork/Node/config.json
	echo "${v_algod_token}" > \
		${v_data_dir}/privatenetwork/Node/algod.token
	echo "${v_algod_admin_token}" > \
		${v_data_dir}/privatenetwork/Node/algod.admin.token
	echo "${v_algod_token}" > \
		${v_data_dir}/privatenetwork/Follower/algod.token
	echo "${v_algod_admin_token}" > \
		${v_data_dir}/privatenetwork/Follower/algod.admin.token
	echo "${v_kmd_token}" > \
		${v_data_dir}/privatenetwork/Node/kmd-v0.5/kmd_config.json
	cp kmd_config.json ${v_data_dir}/privatenetwork/Node/kmd-v0.5/kmd_config.json
	echo "${kmd_token}" > \
		${v_data_dir}/privatenetwork/Node/kmd-v0.5/kmd.token

network-start: network-stop
	${v_bin_dir}/goal network start \
		-r ${v_data_dir}/privatenetwork/

network-stop: kmd-stop
	${v_bin_dir}/goal network stop \
		-r ${v_data_dir}/privatenetwork/ 2>/dev/null || true

network-delete: network-stop
	${v_bin_dir}/goal network delete \
		-r ${v_data_dir}/privatenetwork/ 2>/dev/null || true

network-status:
	${v_bin_dir}/goal network status \
		-r ${v_data_dir}/privatenetwork/

account-list:
	${v_bin_dir}/goal account list \
		-d ${v_data_dir}/privatenetwork/Node

kmd-start:
	${v_bin_dir}/goal kmd start \
		-t 0 \
		-d ${v_data_dir}/privatenetwork/Node

kmd-stop:
	${v_bin_dir}/goal kmd stop \
		-d ${v_data_dir}/privatenetwork/Node 2>/dev/null || true

pgschema-install: pgschema-uninstall
	@cd ./postgres/ && \
		PG_USERNAME="${v_pg_user}" \
		PG_PASSWORD="${v_pg_pass}" \
		PG_HOST="${v_pg_host}" \
		PG_PORT="${v_pg_port}" \
		PG_DBNAME="${v_pg_dbname}" \
		PG_DBSCHEMA="${v_pg_dbschema}" \
		PG_DBUSER="${v_pg_dbuser}" \
		PG_DBPASS="${v_pg_dbpass}" \
		./install.sh

pgschema-uninstall:
	@cd ./postgres/ && \
		PG_USERNAME="${v_pg_user}" \
		PG_PASSWORD="${v_pg_pass}" \
		PG_HOST="${v_pg_host}" \
		PG_PORT="${v_pg_port}" \
		PG_DBNAME="${v_pg_dbname}" \
		PG_DBSCHEMA="${v_pg_dbschema}" \
		PG_DBUSER="${v_pg_dbuser}" \
		PG_DBPASS="${v_pg_dbpass}" \
		./uninstall.sh

conduit-clean:
	rm -rf ${v_conduit_data_dir}/exporter_postgresql/ 2>/dev/null || true
	rm -rf ${v_conduit_data_dir}/importer_algod/ 2>/dev/null || true
	rm -f ${v_conduit_data_dir}/metadata.json 2>/dev/null || true

conduit-start: conduit-clean
	${v_bin_dir}/conduit -d ${v_conduit_data_dir}

indexer-start:
	${v_bin_dir}/algorand-indexer daemon \
		--token "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" \
		--data-dir "${v_data_dir}/indexer" \
		--postgres "host=${v_pg_host} port=${v_pg_port} user=${v_pg_dbuser} password=${v_pg_dbpass} dbname=${v_pg_dbname}"

clean-data: network-delete
	rm -rf ${v_data_dir}/ 2>/dev/null || true

clean: conduit-clean clean-data binaries-clean pgschema-uninstall
