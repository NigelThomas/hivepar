CREATE OR REPLACE SCHEMA "hivepar";
SET SCHEMA '"hivepar"';


CREATE OR REPLACE FOREIGN TABLE "edr_shards" 
( "app_id" INTEGER
, "cell_id" INTEGER
)
SERVER FILE_SERVER
OPTIONS
( "PARSER" 'CSV'
, "CHARACTER_ENCODING" 'UTF-8'
, "QUOTE_CHARACTER" '"'
, "SEPARATOR" ','
, "SKIP_HEADER" 'true'
, "DIRECTORY" '/home/sqlstream/shards'
, "FILENAME_PATTERN" 'shards.csv'
);

CREATE OR REPLACE FOREIGN STREAM "edr_data_fs"
(
    "secs_offset" INTEGER,
    "app_id" INTEGER,
    "cell_id" INTEGER,
    "sn-end-time" VARCHAR(32),
    "sn-start-time" VARCHAR(32),
    "bearer-3gpp imei" VARCHAR(32),
    "bearer-3gpp imsi" BIGINT,
    "bearer-3gpp rat-type" INTEGER,
    "bearer-3gpp user-location-information" VARCHAR(32),
    "ip-server-ip-address" VARCHAR(16),
    "ip-subscriber-ip-address" VARCHAR(64),
    "p2p-tls-sni" VARCHAR(128),
    "radius-calling-station-id" BIGINT,
    "sn-direction" VARCHAR(16),
    "sn-duration" INTEGER,
    "sn-flow-end-time" VARCHAR(32),
    "sn-flow-id" VARCHAR(32),
    "sn-flow-start-time" VARCHAR(32),
    "sn-server-port" INTEGER,
    "sn-subscriber-port" INTEGER,
    "sn-volume-amt-ip-bytes-downlink" INTEGER,
    "sn-volume-amt-ip-bytes-uplink" INTEGER,
    "sn-closure-reason" INTEGER,
    "event-label" VARCHAR(16)
)
    SERVER "FILE_SERVER"

OPTIONS (
"PARSER" 'CSV',
        "CHARACTER_ENCODING" 'UTF-8',
        "QUOTE_CHARACTER" '"',
        "SEPARATOR" ',',
        "SKIP_HEADER" 'false',                          -- headers stripped from files because of bug with REPEAT

        "DIRECTORY" '/home/sqlstream/edr',
        "FILENAME_PATTERN" '.*REPORTOCS.*\.csv',

                                                        -- the sample data set is 600k rows; this expands that to 60M rows and can be changed to 'FOREVER' if needed
	"STATIC_FILES" 'true',
	"REPEAT" '200'

);



-- TODO: manipulate sn_end_time by adding the random secs_offset

-- Filter out any shards we aren't interested in

CREATE OR REPLACE VIEW "edr_data_step_1" 
AS
SELECT STREAM
     char_to_timestamp('MM/dd/yyyy HH:mm:ss:SSS', "sn-end-time") as "event_time"
    , *
FROM "edr_data_fs"
---JOIN "edr_shards" USING("app_id","cell_id")
;

-- Note columns are lower-cased and hyphens and spaces turned to underscores
-- FILE_ROTATION_ROWCOUNT used to force file output

CREATE OR REPLACE FOREIGN STREAM "hive_edr_data"
(
    "min" INTEGER,
    "hour" INTEGER,
    "day" INTEGER,
    "month" INTEGER,
    "year" INTEGER,
    "app_id" INTEGER,
    "cell_id" INTEGER,
    "sn_end_time" VARCHAR(32),
    "sn_start_time" VARCHAR(32),
    "bearer_3gpp_imei" VARCHAR(32),
    "bearer_3gpp_imsi" BIGINT,
    "bearer_3gpp_rat_type" INTEGER,
    "bearer_3gpp_user_location_information" VARCHAR(32),
    "ip_server_ip_address" VARCHAR(16),
    "ip_subscriber_ip_address" VARCHAR(64),
    "p2p_tls_sni" VARCHAR(128),
    "radius_calling_station_id" BIGINT,
    "sn_direction" VARCHAR(16),
    "sn_duration" INTEGER,
    "sn_flow_end_time" VARCHAR(32),
    "sn_flow_id" VARCHAR(32),
    "sn_flow_start_time" VARCHAR(32),
    "sn_server_port" INTEGER,
    "sn_subscriber_port" INTEGER,
    "sn_volume_amt_ip_bytes_downlink" INTEGER,
    "sn_volume_amt_ip_bytes_uplink" INTEGER,
    "sn_closure_reason" INTEGER,
    "event_label" VARCHAR(16),
    "aa_sn_end_time" VARCHAR(32),
    "aa_sn_start_time" VARCHAR(32),
    "aa_bearer_3gpp_imei" VARCHAR(32),
    "aa_bearer_3gpp_imsi" BIGINT,
    "aa_bearer_3gpp_rat_type" INTEGER,
    "aa_bearer_3gpp_user_location_information" VARCHAR(32),
    "aa_ip_server_ip_address" VARCHAR(16),
    "aa_ip_subscriber_ip_address" VARCHAR(64),
    "aa_p2p_tls_sni" VARCHAR(128),
    "aa_radius_calling_station_id" BIGINT,
    "aa_sn_direction" VARCHAR(16),
    "aa_sn_duration" INTEGER,
    "aa_sn_flow_end_time" VARCHAR(32),
    "aa_sn_flow_id" VARCHAR(32),
    "aa_sn_flow_start_time" VARCHAR(32),
    "aa_sn_server_port" INTEGER,
    "aa_sn_subscriber_port" INTEGER,
    "aa_sn_volume_amt_ip_bytes_downlink" INTEGER,
    "aa_sn_volume_amt_ip_bytes_uplink" INTEGER,
    "aa_sn_closure_reason" INTEGER,
    "aa_event_label" VARCHAR(16),
    "bb_sn_end_time" VARCHAR(32),
    "bb_sn_start_time" VARCHAR(32),
    "bb_bearer_3gpp_imei" VARCHAR(32),
    "bb_bearer_3gpp_imsi" BIGINT,
    "bb_bearer_3gpp_rat_type" INTEGER,
    "bb_bearer_3gpp_user_location_information" VARCHAR(32),
    "bb_ip_server_ip_address" VARCHAR(16),
    "bb_ip_subscriber_ip_address" VARCHAR(64),
    "bb_p2p_tls_sni" VARCHAR(128),
    "bb_radius_calling_station_id" BIGINT,
    "bb_sn_direction" VARCHAR(16),
    "bb_sn_duration" INTEGER,
    "bb_sn_flow_end_time" VARCHAR(32),
    "bb_sn_flow_id" VARCHAR(32),
    "bb_sn_flow_start_time" VARCHAR(32),
    "bb_sn_server_port" INTEGER,
    "bb_sn_subscriber_port" INTEGER,
    "bb_sn_volume_amt_ip_bytes_downlink" INTEGER,
    "bb_sn_volume_amt_ip_bytes_uplink" INTEGER,
    "bb_sn_closure_reason" INTEGER,
    "bb_event_label" VARCHAR(16)
)

SERVER HIVE_SERVER

OPTIONS (
    "FORMATTER" 'ORC',
        --"orc.block.padding" 'true',
        --"orc.block.size" '134217728',
        --"orc.direct.encoding.columns" '',
        --"orc.batch.size" '10000',
        "orc.version" 'V_0_11',

        "DIRECTORY" '/home/sqlstream/output',
        "FILENAME_PREFIX" 'edr-out-%HOSTNAME%',
        "FILENAME_SUFFIX" '.orc',
        "FILENAME_DATE_FORMAT" 'yyyy-MM-dd-HH.mm.ss',
        
        
        "FILE_ROTATION_TIME" '%FILE_ROTATION_TIME%',   -- force frequent file rotations
        "ORIGINAL_FILENAME" 'pending-edr.orc',

        
        "HIVE_SCHEMA_NAME" 'hivepar',
        "HIVE_TABLE_NAME" 'hive_edr_hivepar',
        "HIVE_URI" 'jdbc:hive2://sqlstream01-slv-01.cloud.in.guavus.com:2181,sqlstream01-slv-02.cloud.in.guavus.com:2181,sqlstream01-slv-03.cloud.in.guavus.com:2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2-hive2',
        "HIVE_METASTORE_URIS" 'thrift://sqlstream01-mst-01.cloud.in.guavus.com:9083,thrift://sqlstream01-mst-02.cloud.in.guavus.com:9083',
        "CONFIG_PATH" '/home/sqlstream/core-site.xml:/home/sqlstream/hdfs-site.xml',
        "AUTH_METHOD" 'kerberos',
        "AUTH_USERNAME" 'svc_sqlstream_guavus@GVS.GGN',
        "AUTH_KEYTAB" '/home/sqlstream/svc_sqlstream_guavus.keytab',
        "AUTH_METASTORE_PRINCIPAL" 'hive/_HOST@GVS.GGN',
        
        
        "FORMATTER_INCLUDE_ROWTIME" 'false',
        "FILE_ROTATION_RESPECT_ROWTIME" 'false'

    );

-- This pump deals with column renames

CREATE OR REPLACE PUMP "output_pump" STOPPED
AS
INSERT INTO "hive_edr_data"
(
    "min",
    "hour",
    "day",
    "month",
    "year",
    "app_id",
    "cell_id",
    "sn_end_time",
    "sn_start_time",
    "bearer_3gpp_imei",
    "bearer_3gpp_imsi",
    "bearer_3gpp_rat_type",
    "bearer_3gpp_user_location_information",
    "ip_server_ip_address",
    "ip_subscriber_ip_address",
    "p2p_tls_sni",
    "radius_calling_station_id",
    "sn_direction",
    "sn_duration",
    "sn_flow_end_time",
    "sn_flow_id",
    "sn_flow_start_time",
    "sn_server_port",
    "sn_subscriber_port",
    "sn_volume_amt_ip_bytes_downlink",
    "sn_volume_amt_ip_bytes_uplink",
    "sn_closure_reason",
    "event_label",
    "aa_sn_end_time",
    "aa_sn_start_time",
    "aa_bearer_3gpp_imei",
    "aa_bearer_3gpp_imsi",
    "aa_bearer_3gpp_rat_type",
    "aa_bearer_3gpp_user_location_information",
    "aa_ip_server_ip_address",
    "aa_ip_subscriber_ip_address",
    "aa_p2p_tls_sni",
    "aa_radius_calling_station_id",
    "aa_sn_direction",
    "aa_sn_duration",
    "aa_sn_flow_end_time",
    "aa_sn_flow_id",
    "aa_sn_flow_start_time",
    "aa_sn_server_port",
    "aa_sn_subscriber_port",
    "aa_sn_volume_amt_ip_bytes_downlink",
    "aa_sn_volume_amt_ip_bytes_uplink",
    "aa_sn_closure_reason",
    "aa_event_label",
    "bb_sn_end_time",
    "bb_sn_start_time",
    "bb_bearer_3gpp_imei",
    "bb_bearer_3gpp_imsi",
    "bb_bearer_3gpp_rat_type",
    "bb_bearer_3gpp_user_location_information",
    "bb_ip_server_ip_address",
    "bb_ip_subscriber_ip_address",
    "bb_p2p_tls_sni",
    "bb_radius_calling_station_id",
    "bb_sn_direction",
    "bb_sn_duration",
    "bb_sn_flow_end_time",
    "bb_sn_flow_id",
    "bb_sn_flow_start_time",
    "bb_sn_server_port",
    "bb_sn_subscriber_port",
    "bb_sn_volume_amt_ip_bytes_downlink",
    "bb_sn_volume_amt_ip_bytes_uplink",
    "bb_sn_closure_reason",
    "bb_event_label"
)
SELECT STREAM 
    -- partition by columns
    CAST((extract(MINUTE from "event_time")/15)*15 AS INTEGER),
    CAST(extract(HOUR from "event_time") AS INTEGER),
    CAST(extract(DAY from "event_time") AS INTEGER),
    CAST(extract(MONTH from "event_time") AS INTEGER),
    CAST(extract(YEAR from "event_time") AS INTEGER),
    "app_id",
    "cell_id",
    -- data columns
    "sn-end-time",
    "sn-start-time",
    "bearer-3gpp imei",
    "bearer-3gpp imsi",
    "bearer-3gpp rat-type",
    "bearer-3gpp user-location-information",
    "ip-server-ip-address",
    "ip-subscriber-ip-address",
    "p2p-tls-sni",
    "radius-calling-station-id",
    "sn-direction",
    "sn-duration",
    "sn-flow-end-time",
    "sn-flow-id",
    "sn-flow-start-time",
    "sn-server-port",
    "sn-subscriber-port",
    "sn-volume-amt-ip-bytes-downlink",
    "sn-volume-amt-ip-bytes-uplink",
    "sn-closure-reason",
    "event-label",
    -- and repeat original data columns
    "sn-end-time",
    "sn-start-time",
    "bearer-3gpp imei",
    "bearer-3gpp imsi",
    "bearer-3gpp rat-type",
    "bearer-3gpp user-location-information",
    "ip-server-ip-address",
    "ip-subscriber-ip-address",
    "p2p-tls-sni",
    "radius-calling-station-id",
    "sn-direction",
    "sn-duration",
    "sn-flow-end-time",
    "sn-flow-id",
    "sn-flow-start-time",
    "sn-server-port",
    "sn-subscriber-port",
    "sn-volume-amt-ip-bytes-downlink",
    "sn-volume-amt-ip-bytes-uplink",
    "sn-closure-reason",
    "event-label",
    -- and repeat again
    "sn-end-time",
    "sn-start-time",
    "bearer-3gpp imei",
    "bearer-3gpp imsi",
    "bearer-3gpp rat-type",
    "bearer-3gpp user-location-information",
    "ip-server-ip-address",
    "ip-subscriber-ip-address",
    "p2p-tls-sni",
    "radius-calling-station-id",
    "sn-direction",
    "sn-duration",
    "sn-flow-end-time",
    "sn-flow-id",
    "sn-flow-start-time",
    "sn-server-port",
    "sn-subscriber-port",
    "sn-volume-amt-ip-bytes-downlink",
    "sn-volume-amt-ip-bytes-uplink",
    "sn-closure-reason",
    "event-label"
FROM "edr_data_step_1";

