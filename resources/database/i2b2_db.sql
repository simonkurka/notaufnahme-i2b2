--
-- PostgreSQL database dump
--

-- dump of i2b2 database (https://community.i2b2.org/wiki/)
-- but without crc(demo) data and metadata (own data is added instead)

-- Dumped from database version 12.4 (Ubuntu 12.4-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.4 (Ubuntu 12.4-0ubuntu0.20.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: i2b2crcdata; Type: SCHEMA; Schema: -; Owner: i2b2crcdata
--

CREATE SCHEMA i2b2crcdata;


ALTER SCHEMA i2b2crcdata OWNER TO i2b2crcdata;

--
-- Name: i2b2hive; Type: SCHEMA; Schema: -; Owner: i2b2hive
--

CREATE SCHEMA i2b2hive;


ALTER SCHEMA i2b2hive OWNER TO i2b2hive;

--
-- Name: i2b2imdata; Type: SCHEMA; Schema: -; Owner: i2b2imdata
--

CREATE SCHEMA i2b2imdata;


ALTER SCHEMA i2b2imdata OWNER TO i2b2imdata;

--
-- Name: i2b2metadata; Type: SCHEMA; Schema: -; Owner: i2b2metadata
--

CREATE SCHEMA i2b2metadata;


ALTER SCHEMA i2b2metadata OWNER TO i2b2metadata;

--
-- Name: i2b2pm; Type: SCHEMA; Schema: -; Owner: i2b2pm
--

CREATE SCHEMA i2b2pm;


ALTER SCHEMA i2b2pm OWNER TO i2b2pm;

--
-- Name: i2b2workdata; Type: SCHEMA; Schema: -; Owner: i2b2workdata
--

CREATE SCHEMA i2b2workdata;


ALTER SCHEMA i2b2workdata OWNER TO i2b2workdata;

--
-- Name: create_temp_concept_table(text); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.create_temp_concept_table(tempconcepttablename text, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN 
    EXECUTE 'create table ' ||  tempConceptTableName || ' (
        CONCEPT_CD varchar(50) NOT NULL, 
        CONCEPT_PATH varchar(900) NOT NULL , 
        NAME_CHAR varchar(2000), 
        CONCEPT_BLOB text, 
        UPDATE_DATE timestamp, 
        DOWNLOAD_DATE timestamp, 
        IMPORT_DATE timestamp, 
        SOURCESYSTEM_CD varchar(50)
    ) WITH OIDS';
    EXECUTE 'CREATE INDEX idx_' || tempConceptTableName || '_pat_id ON ' || tempConceptTableName || '  (CONCEPT_PATH)';
    EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;      
END;
$$;


ALTER FUNCTION i2b2crcdata.create_temp_concept_table(tempconcepttablename text, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: create_temp_eid_table(text); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.create_temp_eid_table(temppatientmappingtablename text, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN 
    EXECUTE 'create table ' ||  tempPatientMappingTableName || ' (
        ENCOUNTER_MAP_ID        varchar(200) NOT NULL,
        ENCOUNTER_MAP_ID_SOURCE     varchar(50) NOT NULL,
        PATIENT_MAP_ID          varchar(200), 
        PATIENT_MAP_ID_SOURCE   varchar(50), 
        ENCOUNTER_ID            varchar(200) NOT NULL,
        ENCOUNTER_ID_SOURCE     varchar(50) ,
        ENCOUNTER_NUM           numeric, 
        ENCOUNTER_MAP_ID_STATUS    varchar(50),
        PROCESS_STATUS_FLAG     char(1),
        UPDATE_DATE timestamp, 
        DOWNLOAD_DATE timestamp, 
        IMPORT_DATE timestamp, 
        SOURCESYSTEM_CD varchar(50)
    ) WITH OIDS';
    EXECUTE 'CREATE INDEX idx_' || tempPatientMappingTableName || '_eid_id ON ' || tempPatientMappingTableName || '  (ENCOUNTER_ID, ENCOUNTER_ID_SOURCE, ENCOUNTER_MAP_ID, ENCOUNTER_MAP_ID_SOURCE, ENCOUNTER_NUM)';
    EXECUTE 'CREATE INDEX idx_' || tempPatientMappingTableName || '_stateid_eid_id ON ' || tempPatientMappingTableName || '  (PROCESS_STATUS_FLAG)';  
    EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '%%%', SQLSTATE || ' - ' || SQLERRM;
END;
$$;


ALTER FUNCTION i2b2crcdata.create_temp_eid_table(temppatientmappingtablename text, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: create_temp_modifier_table(text); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.create_temp_modifier_table(tempmodifiertablename text, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN 
EXECUTE 'create table ' ||  tempModifierTableName || ' (
        MODIFIER_CD varchar(50) NOT NULL, 
        MODIFIER_PATH varchar(900) NOT NULL , 
        NAME_CHAR varchar(2000), 
        MODIFIER_BLOB text, 
        UPDATE_DATE timestamp, 
        DOWNLOAD_DATE timestamp, 
        IMPORT_DATE timestamp, 
        SOURCESYSTEM_CD varchar(50)
         ) WITH OIDS';
 EXECUTE 'CREATE INDEX idx_' || tempModifierTableName || '_pat_id ON ' || tempModifierTableName || '  (MODIFIER_PATH)';
EXCEPTION
        WHEN OTHERS THEN
        RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;      
END;
$$;


ALTER FUNCTION i2b2crcdata.create_temp_modifier_table(tempmodifiertablename text, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: create_temp_patient_table(text); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.create_temp_patient_table(temppatientdimensiontablename text, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN 
    -- Create temp table to store encounter/visit information
    EXECUTE 'create table ' ||  tempPatientDimensionTableName || ' (
        patient_id varchar(200), 
        patient_id_source varchar(50),
        patient_num numeric(38,0),
        vital_status_cd varchar(50), 
        birth_date timestamp, 
        death_date timestamp, 
        sex_cd char(50), 
        age_in_years_num numeric(5,0), 
        language_cd varchar(50), 
        race_cd varchar(50 ), 
        marital_status_cd varchar(50), 
        religion_cd varchar(50), 
        zip_cd varchar(50), 
        statecityzip_path varchar(700), 
        patient_blob text, 
        update_date timestamp, 
        download_date timestamp, 
        import_date timestamp, 
        sourcesystem_cd varchar(50)
    )';
    EXECUTE 'CREATE INDEX idx_' || tempPatientDimensionTableName || '_pat_id ON ' || tempPatientDimensionTableName || '  (patient_id, patient_id_source,patient_num)';
    EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '%%%', SQLSTATE || ' - ' || SQLERRM;
END;
$$;


ALTER FUNCTION i2b2crcdata.create_temp_patient_table(temppatientdimensiontablename text, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: create_temp_pid_table(text); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.create_temp_pid_table(temppatientmappingtablename text, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN 
	EXECUTE 'create table ' ||  tempPatientMappingTableName || ' (
		PATIENT_MAP_ID varchar(200), 
		PATIENT_MAP_ID_SOURCE varchar(50), 
		PATIENT_ID_STATUS varchar(50), 
		PATIENT_ID  varchar(200),
		PATIENT_ID_SOURCE varchar(50),
		PATIENT_NUM numeric(38,0),
		PATIENT_MAP_ID_STATUS varchar(50), 
		PROCESS_STATUS_FLAG char(1), 
		UPDATE_DATE timestamp, 
		DOWNLOAD_DATE timestamp, 
		IMPORT_DATE timestamp, 
		SOURCESYSTEM_CD varchar(50)
	) WITH OIDS';
	EXECUTE 'CREATE INDEX idx_' || tempPatientMappingTableName || '_pid_id ON ' || tempPatientMappingTableName || '  ( PATIENT_ID, PATIENT_ID_SOURCE )';
	EXECUTE 'CREATE INDEX idx_' || tempPatientMappingTableName || 'map_pid_id ON ' || tempPatientMappingTableName || '  
	( PATIENT_ID, PATIENT_ID_SOURCE,PATIENT_MAP_ID, PATIENT_MAP_ID_SOURCE,  PATIENT_NUM )';
	EXECUTE 'CREATE INDEX idx_' || tempPatientMappingTableName || 'stat_pid_id ON ' || tempPatientMappingTableName || '  
	(PROCESS_STATUS_FLAG)';
	EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE '%%%', SQLSTATE || ' - ' || SQLERRM;
END;
$$;


ALTER FUNCTION i2b2crcdata.create_temp_pid_table(temppatientmappingtablename text, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: create_temp_provider_table(text); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.create_temp_provider_table(tempprovidertablename text, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN 
    EXECUTE 'create table ' ||  tempProviderTableName || ' (
        PROVIDER_ID varchar(50) NOT NULL, 
        PROVIDER_PATH varchar(700) NOT NULL, 
        NAME_CHAR varchar(2000), 
        PROVIDER_BLOB text, 
        UPDATE_DATE timestamp, 
        DOWNLOAD_DATE timestamp, 
        IMPORT_DATE timestamp, 
        SOURCESYSTEM_CD varchar(50), 
        UPLOAD_ID numeric
    ) WITH OIDS';
    EXECUTE 'CREATE INDEX idx_' || tempProviderTableName || '_ppath_id ON ' || tempProviderTableName || '  (PROVIDER_PATH)';
    EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;      

END;
$$;


ALTER FUNCTION i2b2crcdata.create_temp_provider_table(tempprovidertablename text, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: create_temp_table(text); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.create_temp_table(temptablename text, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN 
    EXECUTE 'create table ' ||  tempTableName || '  (
        encounter_num  numeric(38,0),
        encounter_id varchar(200) not null, 
        encounter_id_source varchar(50) not null,
        concept_cd       varchar(50) not null, 
        patient_num numeric(38,0), 
        patient_id  varchar(200) not null,
        patient_id_source  varchar(50) not null,
        provider_id   varchar(50),
        start_date   timestamp, 
        modifier_cd varchar(100),
        instance_num numeric(18,0),
        valtype_cd varchar(50),
        tval_char varchar(255),
        nval_num numeric(18,5),
        valueflag_cd char(50),
        quantity_num numeric(18,5),
        confidence_num numeric(18,0),
        observation_blob text,
        units_cd varchar(50),
        end_date    timestamp,
        location_cd varchar(50),
        update_date  timestamp,
        download_date timestamp,
        import_date timestamp,
        sourcesystem_cd varchar(50) ,
        upload_id integer
    ) WITH OIDS';
    EXECUTE 'CREATE INDEX idx_' || tempTableName || '_pk ON ' || tempTableName || '  ( encounter_num,patient_num,concept_cd,provider_id,start_date,modifier_cd,instance_num)';
    EXECUTE 'CREATE INDEX idx_' || tempTableName || '_enc_pat_id ON ' || tempTableName || '  (encounter_id,encounter_id_source, patient_id,patient_id_source )';
    EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM; 
END;
$$;


ALTER FUNCTION i2b2crcdata.create_temp_table(temptablename text, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: create_temp_visit_table(text); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.create_temp_visit_table(temptablename text, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN 
    -- Create temp table to store encounter/visit information
    EXECUTE 'create table ' ||  tempTableName || ' (
        encounter_id                    varchar(200) not null,
        encounter_id_source             varchar(50) not null, 
        project_id                      varchar(50) not null,
        patient_id                      varchar(200) not null,
        patient_id_source               varchar(50) not null,
        encounter_num                   numeric(38,0), 
        inout_cd                        varchar(50),
        location_cd                     varchar(50),
        location_path                   varchar(900),
        start_date                      timestamp, 
        end_date                        timestamp,
        visit_blob                      text,
        update_date                     timestamp,
        download_date                   timestamp,
        import_date                     timestamp,
        sourcesystem_cd                 varchar(50)
    ) WITH OIDS';
    EXECUTE 'CREATE INDEX idx_' || tempTableName || '_enc_id ON ' || tempTableName || '  ( encounter_id,encounter_id_source,patient_id,patient_id_source )';
    EXECUTE 'CREATE INDEX idx_' || tempTableName || '_patient_id ON ' || tempTableName || '  ( patient_id,patient_id_source )';
    EXCEPTION
    WHEN OTHERS THEN    
        RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;    
END;
$$;


ALTER FUNCTION i2b2crcdata.create_temp_visit_table(temptablename text, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: insert_concept_fromtemp(text, bigint); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.insert_concept_fromtemp(tempconcepttablename text, upload_id bigint, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN 
    --Delete duplicate rows with same encounter and patient combination
    EXECUTE 'DELETE 
    FROM
    ' || tempConceptTableName || ' t1 
    WHERE
    oid > (SELECT  
        min(oid) 
        FROM 
        ' || tempConceptTableName || ' t2
        WHERE 
        t1.concept_cd = t2.concept_cd 
        AND t1.concept_path = t2.concept_path
    )';
    EXECUTE ' UPDATE concept_dimension  
    SET  
    concept_cd=temp.concept_cd
    ,name_char=temp.name_char
    ,concept_blob=temp.concept_blob
    ,update_date=temp.update_date
    ,download_date=temp.download_date
    ,import_date=Now()
    ,sourcesystem_cd=temp.sourcesystem_cd
    ,upload_id=' || UPLOAD_ID  || '
    FROM 
    ' || tempConceptTableName || '  temp   
    WHERE 
    temp.concept_path = concept_dimension.concept_path 
    AND temp.update_date >= concept_dimension.update_date 
    AND EXISTS (SELECT 1 
        FROM ' || tempConceptTableName || ' temp  
        WHERE temp.concept_path = concept_dimension.concept_path 
        AND temp.update_date >= concept_dimension.update_date
    )
    ';
    --Create new patient(patient_mapping) if temp table patient_ide does not exists 
    -- in patient_mapping table.
    EXECUTE 'INSERT INTO concept_dimension  (
        concept_cd
        ,concept_path
        ,name_char
        ,concept_blob
        ,update_date
        ,download_date
        ,import_date
        ,sourcesystem_cd
        ,upload_id
    )
    SELECT  
    concept_cd
    ,concept_path
    ,name_char
    ,concept_blob
    ,update_date
    ,download_date
    ,Now()
    ,sourcesystem_cd
    ,' || upload_id || '
    FROM ' || tempConceptTableName || '  temp
    WHERE NOT EXISTS (SELECT concept_cd 
        FROM concept_dimension cd 
        WHERE cd.concept_path = temp.concept_path)
    ';
    EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;      
END;
$$;


ALTER FUNCTION i2b2crcdata.insert_concept_fromtemp(tempconcepttablename text, upload_id bigint, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: insert_eid_map_fromtemp(text, bigint); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.insert_eid_map_fromtemp(tempeidtablename text, upload_id bigint, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE

existingEncounterNum varchar(32);
maxEncounterNum bigint;
distinctEidCur REFCURSOR;
disEncounterId varchar(100); 
disEncounterIdSource varchar(100);
disPatientId varchar(100);
disPatientIdSource varchar(100);

BEGIN
    EXECUTE ' delete  from ' || tempEidTableName ||  ' t1  where 
    oid > (select min(oid) from ' || tempEidTableName || ' t2 
        where t1.encounter_map_id = t2.encounter_map_id
        and t1.encounter_map_id_source = t2.encounter_map_id_source
        and t1.encounter_id = t2.encounter_id
        and t1.encounter_id_source = t2.encounter_id_source) ';
    LOCK TABLE  encounter_mapping IN EXCLUSIVE MODE NOWAIT;
    select max(encounter_num) into STRICT  maxEncounterNum from encounter_mapping ; 
    if coalesce(maxEncounterNum::text, '') = '' then 
        maxEncounterNum := 0;
    end if;
    open distinctEidCur for EXECUTE 'SELECT distinct encounter_id,encounter_id_source,patient_map_id,patient_map_id_source from ' || tempEidTableName ||' ' ;
    loop
        FETCH distinctEidCur INTO disEncounterId, disEncounterIdSource,disPatientId,disPatientIdSource;
        IF NOT FOUND THEN EXIT; END IF; 
            
            if  disEncounterIdSource = 'HIVE'  THEN 
                begin
                    
                    select encounter_num into existingEncounterNum from encounter_mapping where encounter_num = CAST(disEncounterId AS numeric) and encounter_ide_source = 'HIVE';
                    EXCEPTION  when NO_DATA_FOUND THEN
                        existingEncounterNum := null;
                end;
                if (existingEncounterNum IS NOT NULL AND existingEncounterNum::text <> '') then 
                    EXECUTE ' update ' || tempEidTableName ||' set encounter_num = CAST(encounter_id AS numeric), process_status_flag = ''P''
                    where encounter_id = $1 and not exists (select 1 from encounter_mapping em where em.encounter_ide = encounter_map_id
                        and em.encounter_ide_source = encounter_map_id_source)' using disEncounterId;
                else 
                    
                    if maxEncounterNum < CAST(disEncounterId AS numeric) then 
                        maxEncounterNum := disEncounterId;
                    end if ;
                    EXECUTE ' update ' || tempEidTableName ||' set encounter_num = CAST(encounter_id AS numeric), process_status_flag = ''P'' where 
                    encounter_id =  $1 and encounter_id_source = ''HIVE'' and not exists (select 1 from encounter_mapping em where em.encounter_ide = encounter_map_id
                        and em.encounter_ide_source = encounter_map_id_source)' using disEncounterId;
                end if;    
                
                
            else 
                begin
                    select encounter_num into STRICT  existingEncounterNum from encounter_mapping where encounter_ide = disEncounterId and 
                    encounter_ide_source = disEncounterIdSource and patient_ide=disPatientId and patient_ide_source=disPatientIdSource; 
                    
                    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        existingEncounterNum := null;
                end;
                if existingEncounterNum is not  null then 
                    EXECUTE ' update ' || tempEidTableName ||' set encounter_num = CAST($1 AS numeric) , process_status_flag = ''P''
                    where encounter_id = $2 and not exists (select 1 from encounter_mapping em where em.encounter_ide = encounter_map_id
                        and em.encounter_ide_source = encounter_map_id_source and em.patient_ide_source = patient_map_id_source and em.patient_ide=patient_map_id)' using existingEncounterNum, disEncounterId;
                else 
                    maxEncounterNum := maxEncounterNum + 1 ;
                    
                    EXECUTE ' insert into ' || tempEidTableName ||' (encounter_map_id,encounter_map_id_source,encounter_id,encounter_id_source,encounter_num,process_status_flag
                        ,encounter_map_id_status,update_date,download_date,import_date,sourcesystem_cd,patient_map_id,patient_map_id_source) 
                    values($1,''HIVE'',$2,''HIVE'',$3,''P'',''A'',Now(),Now(),Now(),''edu.harvard.i2b2.crc'',$4,$5)' using maxEncounterNum,maxEncounterNum,maxEncounterNum,disPatientId,disPatientIdSource; 
                    EXECUTE ' update ' || tempEidTableName ||' set encounter_num =  $1 , process_status_flag = ''P'' 
                    where encounter_id = $2 and  not exists (select 1 from 
                        encounter_mapping em where em.encounter_ide = encounter_map_id
                        and em.encounter_ide_source = encounter_map_id_source
                        and em.patient_ide_source = patient_map_id_source and em.patient_ide=patient_map_id)' using maxEncounterNum, disEncounterId;
                end if ;
                
            end if; 
    END LOOP;
    close distinctEidCur ;
    

EXECUTE 'UPDATE encounter_mapping
SET 
encounter_num = CAST(temp.encounter_id AS numeric)
,encounter_ide_status = temp.encounter_map_id_status
,patient_ide   =   temp.patient_map_id 
,patient_ide_source  =	temp.patient_map_id_source 
,update_date = temp.update_date
,download_date  = temp.download_date
,import_date = Now()
,sourcesystem_cd  = temp.sourcesystem_cd
,upload_id = ' || upload_id ||'
FROM '|| tempEidTableName || '  temp
WHERE 
temp.encounter_map_id = encounter_mapping.encounter_ide 
and temp.encounter_map_id_source = encounter_mapping.encounter_ide_source
and temp.patient_map_id = encounter_mapping.patient_ide 
and temp.patient_map_id_source = encounter_mapping.patient_ide_source
and temp.encounter_id_source = ''HIVE''
and coalesce(temp.process_status_flag::text, '''') = ''''  
and coalesce(encounter_mapping.update_date,to_date(''01-JAN-1900'',''DD-MON-YYYY'')) <= coalesce(temp.update_date,to_date(''01-JAN-1900'',''DD-MON-YYYY''))
';

    
    EXECUTE ' insert into encounter_mapping (encounter_ide,encounter_ide_source,encounter_ide_status,encounter_num,patient_ide,patient_ide_source,update_date,download_date,import_date,sourcesystem_cd,upload_id,project_id) 
    SELECT encounter_map_id,encounter_map_id_source,encounter_map_id_status,encounter_num,patient_map_id,patient_map_id_source,update_date,download_date,Now(),sourcesystem_cd,' || upload_id || ' , ''@'' project_id
    FROM ' || tempEidTableName || '  
    WHERE process_status_flag = ''P'' ' ; 
    EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;
    end;
     $_$;


ALTER FUNCTION i2b2crcdata.insert_eid_map_fromtemp(tempeidtablename text, upload_id bigint, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: insert_encountervisit_fromtemp(text, bigint); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.insert_encountervisit_fromtemp(temptablename text, upload_id bigint, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE

maxEncounterNum bigint; 

BEGIN 
    --Delete duplicate rows with same encounter and patient combination
    EXECUTE 'DELETE FROM ' || tempTableName || ' t1 WHERE oid > 
    (SELECT  min(oid) FROM ' || tempTableName || ' t2
        WHERE t1.encounter_id = t2.encounter_id 
        AND t1.encounter_id_source = t2.encounter_id_source
        AND coalesce(t1.patient_id,'''') = coalesce(t2.patient_id,'''')
        AND coalesce(t1.patient_id_source,'''') = coalesce(t2.patient_id_source,''''))';
    LOCK TABLE  encounter_mapping IN EXCLUSIVE MODE NOWAIT;
    -- select max(encounter_num) into maxEncounterNum from encounter_mapping ;
    --Create new patient(patient_mapping) if temp table patient_ide does not exists 
    -- in patient_mapping table.
    EXECUTE 'INSERT INTO encounter_mapping (
        encounter_ide
        , encounter_ide_source
        , encounter_num
        , patient_ide
        , patient_ide_source
        , encounter_ide_status
        , upload_id
        , project_id
    )
    (SELECT 
        distinctTemp.encounter_id
        , distinctTemp.encounter_id_source
        , CAST(distinctTemp.encounter_id AS numeric)
        , distinctTemp.patient_id
        , distinctTemp.patient_id_source
        , ''A''
        ,  '|| upload_id ||'
        , distinctTemp.project_id
        FROM 
        (SELECT 
            distinct encounter_id
            , encounter_id_source
            , patient_id
            , patient_id_source 
            , project_id
            FROM ' || tempTableName || '  temp
            WHERE 
            NOT EXISTS (SELECT encounter_ide 
                FROM encounter_mapping em 
                WHERE 
                em.encounter_ide = temp.encounter_id 
                AND em.encounter_ide_source = temp.encounter_id_source
            )
            AND encounter_id_source = ''HIVE'' 
    )   distinctTemp
) ' ;
    -- update patient_num for temp table
    EXECUTE ' UPDATE ' ||  tempTableName
    || ' SET encounter_num = (SELECT em.encounter_num
        FROM encounter_mapping em
        WHERE em.encounter_ide = '|| tempTableName ||'.encounter_id
        and em.encounter_ide_source = '|| tempTableName ||'.encounter_id_source 
        and coalesce(em.patient_ide_source,'''') = coalesce('|| tempTableName ||'.patient_id_source,'''')
        and coalesce(em.patient_ide,'''')= coalesce('|| tempTableName ||'.patient_id,'''')
    )
    WHERE EXISTS (SELECT em.encounter_num 
        FROM encounter_mapping em
        WHERE em.encounter_ide = '|| tempTableName ||'.encounter_id
        and em.encounter_ide_source = '||tempTableName||'.encounter_id_source
        and coalesce(em.patient_ide_source,'''') = coalesce('|| tempTableName ||'.patient_id_source,'''')
        and coalesce(em.patient_ide,'''')= coalesce('|| tempTableName ||'.patient_id,''''))';      

    EXECUTE ' UPDATE visit_dimension  SET  
    start_date =temp.start_date
    ,end_date=temp.end_date
    ,inout_cd=temp.inout_cd
    ,location_cd=temp.location_cd
    ,visit_blob=temp.visit_blob
    ,update_date=temp.update_date
    ,download_date=temp.download_date
    ,import_date=Now()
    ,sourcesystem_cd=temp.sourcesystem_cd
    , upload_id=' || UPLOAD_ID  || '
    FROM ' || tempTableName || '  temp       
    WHERE
    temp.encounter_num = visit_dimension.encounter_num 
    AND temp.update_date >= visit_dimension.update_date 
    AND exists (SELECT 1 
        FROM ' || tempTableName || ' temp 
        WHERE temp.encounter_num = visit_dimension.encounter_num 
        AND temp.update_date >= visit_dimension.update_date
    ) ';

    EXECUTE 'INSERT INTO visit_dimension  (encounter_num,patient_num,start_date,end_date,inout_cd,location_cd,visit_blob,update_date,download_date,import_date,sourcesystem_cd, upload_id)
    SELECT temp.encounter_num
    , pm.patient_num,
    temp.start_date,temp.end_date,temp.inout_cd,temp.location_cd,temp.visit_blob,
    temp.update_date,
    temp.download_date,
    Now(), 
    temp.sourcesystem_cd,
    '|| upload_id ||'
    FROM 
    ' || tempTableName || '  temp , patient_mapping pm 
    WHERE 
    (temp.encounter_num IS NOT NULL AND temp.encounter_num::text <> '''') and 
    NOT EXISTS (SELECT encounter_num 
        FROM visit_dimension vd 
        WHERE 
        vd.encounter_num = temp.encounter_num) 
    AND pm.patient_ide = temp.patient_id 
    AND pm.patient_ide_source = temp.patient_id_source
    ';
    EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;      
END;
$$;


ALTER FUNCTION i2b2crcdata.insert_encountervisit_fromtemp(temptablename text, upload_id bigint, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: insert_modifier_fromtemp(text, bigint); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.insert_modifier_fromtemp(tempmodifiertablename text, upload_id bigint, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN 
    --Delete duplicate rows 
    EXECUTE 'DELETE FROM ' || tempModifierTableName || ' t1 WHERE oid > 
    (SELECT  min(oid) FROM ' || tempModifierTableName || ' t2
        WHERE t1.modifier_cd = t2.modifier_cd 
        AND t1.modifier_path = t2.modifier_path
    )';
    EXECUTE ' UPDATE modifier_dimension  SET  
        modifier_cd=temp.modifier_cd
        ,name_char=temp.name_char
        ,modifier_blob=temp.modifier_blob
        ,update_date=temp.update_date
        ,download_date=temp.download_date
        ,import_date=Now()
        ,sourcesystem_cd=temp.SOURCESYSTEM_CD
        ,upload_id=' || UPLOAD_ID  || ' 
        FROM ' || tempModifierTableName || '  temp
        WHERE 
        temp.modifier_path = modifier_dimension.modifier_path 
        AND temp.update_date >= modifier_dimension.update_date
        AND EXISTS (SELECT 1 
            FROM ' || tempModifierTableName || ' temp  
            WHERE temp.modifier_path = modifier_dimension.modifier_path 
            AND temp.update_date >= modifier_dimension.update_date)
        ';
        --Create new modifier if temp table modifier_path does not exists 
        -- in modifier dimension table.
        EXECUTE 'INSERT INTO modifier_dimension  (
            modifier_cd
            ,modifier_path
            ,name_char
            ,modifier_blob
            ,update_date
            ,download_date
            ,import_date
            ,sourcesystem_cd
            ,upload_id
        )
        SELECT  
        modifier_cd
        ,modifier_path
        ,name_char
        ,modifier_blob
        ,update_date
        ,download_date
        ,Now()
        ,sourcesystem_cd
        ,' || upload_id || '  
        FROM
        ' || tempModifierTableName || '  temp
        WHERE NOT EXISTs (SELECT modifier_cd 
            FROM modifier_dimension cd
            WHERE cd.modifier_path = temp.modifier_path
        )
        ';
        EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;      
END;
$$;


ALTER FUNCTION i2b2crcdata.insert_modifier_fromtemp(tempmodifiertablename text, upload_id bigint, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: insert_patient_fromtemp(text, bigint); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.insert_patient_fromtemp(temptablename text, upload_id bigint, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE

maxPatientNum bigint; 

BEGIN 
    LOCK TABLE  patient_mapping IN EXCLUSIVE MODE NOWAIT;
    --select max(patient_num) into maxPatientNum from patient_mapping ;
    --Create new patient(patient_mapping) if temp table patient_ide does not exists 
    -- in patient_mapping table.
    EXECUTE ' INSERT INTO patient_mapping (patient_ide,patient_ide_source,patient_num,patient_ide_status, upload_id)
    (SELECT distinctTemp.patient_id, distinctTemp.patient_id_source, CAST(distinctTemp.patient_id AS numeric), ''A'',   '|| upload_id ||'
        FROM 
        (SELECT distinct patient_id, patient_id_source from ' || tempTableName || '  temp
            where  not exists (SELECT patient_ide from patient_mapping pm where pm.patient_ide = temp.patient_id and pm.patient_ide_source = temp.patient_id_source)
            and patient_id_source = ''HIVE'' )   distinctTemp) ';

    -- update patient_num for temp table
    EXECUTE ' UPDATE ' ||  tempTableName
    || ' SET patient_num = (SELECT pm.patient_num
        FROM patient_mapping pm
        WHERE pm.patient_ide = '|| tempTableName ||'.patient_id
        AND pm.patient_ide_source = '|| tempTableName ||'.patient_id_source
    )
    WHERE EXISTS (SELECT pm.patient_num 
        FROM patient_mapping pm
        WHERE pm.patient_ide = '|| tempTableName ||'.patient_id
        AND pm.patient_ide_source = '||tempTableName||'.patient_id_source)';       

    EXECUTE ' UPDATE patient_dimension  SET  
    vital_status_cd = temp.vital_status_cd
    , birth_date = temp.birth_date
    , death_date = temp.death_date
    , sex_cd = temp.sex_cd
    , age_in_years_num = temp.age_in_years_num
    , language_cd = temp.language_cd
    , race_cd = temp.race_cd
    , marital_status_cd = temp.marital_status_cd
    , religion_cd = temp.religion_cd
    , zip_cd = temp.zip_cd
    , statecityzip_path = temp.statecityzip_path
    , patient_blob = temp.patient_blob
    , update_date = temp.update_date
    , download_date = temp.download_date
    , import_date = Now()
    , sourcesystem_cd = temp.sourcesystem_cd 
    , upload_id =  ' || UPLOAD_ID  || '
    FROM  ' || tempTableName || '  temp
    WHERE 
    temp.patient_num = patient_dimension.patient_num 
    AND temp.update_date >= patient_dimension.update_date
    AND EXISTS (select 1 
        FROM ' || tempTableName || ' temp  
        WHERE 
        temp.patient_num = patient_dimension.patient_num 
        AND temp.update_date >= patient_dimension.update_date
    )    ';

    --Create new patient(patient_dimension) for above inserted patient's.
    --If patient_dimension table's patient num does match temp table,
    --then new patient_dimension information is inserted.
    EXECUTE 'INSERT INTO patient_dimension  (patient_num,vital_status_cd, birth_date, death_date,
        sex_cd, age_in_years_num,language_cd,race_cd,marital_status_cd, religion_cd,
        zip_cd,statecityzip_path,patient_blob,update_date,download_date,import_date,sourcesystem_cd,
        upload_id)
    SELECT temp.patient_num,
    temp.vital_status_cd, temp.birth_date, temp.death_date,
    temp.sex_cd, temp.age_in_years_num,temp.language_cd,temp.race_cd,temp.marital_status_cd, temp.religion_cd,
    temp.zip_cd,temp.statecityzip_path,temp.patient_blob,
    temp.update_date,
    temp.download_date,
    Now(),
    temp.sourcesystem_cd,
    '|| upload_id ||'
    FROM 
    ' || tempTableName || '  temp 
    WHERE 
    NOT EXISTS (SELECT patient_num 
        FROM patient_dimension pd 
        WHERE pd.patient_num = temp.patient_num) 
    AND 
    (patient_num IS NOT NULL AND patient_num::text <> '''')
    ';
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;

END;
$$;


ALTER FUNCTION i2b2crcdata.insert_patient_fromtemp(temptablename text, upload_id bigint, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: insert_patient_map_fromtemp(text, bigint); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.insert_patient_map_fromtemp(temppatienttablename text, upload_id bigint, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN 
        --Create new patient mapping entry for HIVE patient's if they are not already mapped in mapping table
        EXECUTE 'insert into patient_mapping (
                PERFORM distinct temp.patient_id, temp.patient_id_source,''A'',temp.patient_id ,' || upload_id || '
                from ' || tempPatientTableName ||'  temp 
                where temp.patient_id_source = ''HIVE'' and 
                not exists (select patient_ide from patient_mapping pm where pm.patient_num = temp.patient_id and pm.patient_ide_source = temp.patient_id_source) 
                )'; 
    --Create new visit for above inserted encounter's
        --If Visit table's encounter and patient num does match temp table,
        --then new visit information is created.
        EXECUTE 'MERGE  INTO patient_dimension pd
                   USING ( select case when (ptemp.patient_id_source=''HIVE'') then  cast(ptemp.patient_id as int)
                                       else pmap.patient_num end patient_num,
                                  ptemp.VITAL_STATUS_CD, 
                                  ptemp.BIRTH_DATE,
                                  ptemp.DEATH_DATE, 
                                  ptemp.SEX_CD ,
                                  ptemp.AGE_IN_YEARS_NUM,
                                  ptemp.LANGUAGE_CD,
                                  ptemp.RACE_CD,
                                  ptemp.MARITAL_STATUS_CD,
                                  ptemp.RELIGION_CD,
                                  ptemp.ZIP_CD,
                                                                  ptemp.STATECITYZIP_PATH , 
                                                                  ptemp.PATIENT_BLOB, 
                                                                  ptemp.UPDATE_DATE, 
                                                                  ptemp.DOWNLOAD_DATE, 
                                                                  ptemp.IMPORT_DATE, 
                                                                  ptemp.SOURCESYSTEM_CD
                   from ' || tempPatientTableName || '  ptemp , patient_mapping pmap
                   where   ptemp.patient_id = pmap.patient_ide(+)
                   and ptemp.patient_id_source = pmap.patient_ide_source(+)
           ) temp
                   on (
                                pd.patient_num = temp.patient_num
                    )    
                        when matched then 
                                update  set 
                                        pd.VITAL_STATUS_CD= temp.VITAL_STATUS_CD,
                    pd.BIRTH_DATE= temp.BIRTH_DATE,
                    pd.DEATH_DATE= temp.DEATH_DATE,
                    pd.SEX_CD= temp.SEX_CD,
                    pd.AGE_IN_YEARS_NUM=temp.AGE_IN_YEARS_NUM,
                    pd.LANGUAGE_CD=temp.LANGUAGE_CD,
                    pd.RACE_CD=temp.RACE_CD,
                    pd.MARITAL_STATUS_CD=temp.MARITAL_STATUS_CD,
                    pd.RELIGION_CD=temp.RELIGION_CD,
                    pd.ZIP_CD=temp.ZIP_CD,
                                        pd.STATECITYZIP_PATH =temp.STATECITYZIP_PATH,
                                        pd.PATIENT_BLOB=temp.PATIENT_BLOB,
                                        pd.UPDATE_DATE=temp.UPDATE_DATE,
                                        pd.DOWNLOAD_DATE=temp.DOWNLOAD_DATE,
                                        pd.SOURCESYSTEM_CD=temp.SOURCESYSTEM_CD,
                                        pd.UPLOAD_ID = '||upload_id||'
                    where temp.update_date > pd.update_date
                         when not matched then 
                                insert (
                                        PATIENT_NUM,
                                        VITAL_STATUS_CD,
                    BIRTH_DATE,
                    DEATH_DATE,
                    SEX_CD,
                    AGE_IN_YEARS_NUM,
                    LANGUAGE_CD,
                    RACE_CD,
                    MARITAL_STATUS_CD,
                    RELIGION_CD,
                    ZIP_CD,
                                        STATECITYZIP_PATH,
                                        PATIENT_BLOB,
                                        UPDATE_DATE,
                                        DOWNLOAD_DATE,
                                        SOURCESYSTEM_CD,
                                        import_date,
                        upload_id
                                        ) 
                                values (
                                        temp.PATIENT_NUM,
                                        temp.VITAL_STATUS_CD,
                    temp.BIRTH_DATE,
                    temp.DEATH_DATE,
                    temp.SEX_CD,
                    temp.AGE_IN_YEARS_NUM,
                    temp.LANGUAGE_CD,
                    temp.RACE_CD,
                    temp.MARITAL_STATUS_CD,
                    temp.RELIGION_CD,
                    temp.ZIP_CD,
                                        temp.STATECITYZIP_PATH,
                                        temp.PATIENT_BLOB,
                                        temp.UPDATE_DATE,
                                        temp.DOWNLOAD_DATE,
                                        temp.SOURCESYSTEM_CD,
                                        LOCALTIMESTAMP,
                                '||upload_id||'
                                )';
EXCEPTION
        WHEN OTHERS THEN
                RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;      
END;
$$;


ALTER FUNCTION i2b2crcdata.insert_patient_map_fromtemp(temppatienttablename text, upload_id bigint, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: insert_pid_map_fromtemp(text, bigint); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.insert_pid_map_fromtemp(temppidtablename text, upload_id bigint, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
existingPatientNum varchar(32);
maxPatientNum bigint;
distinctPidCur REFCURSOR;
disPatientId varchar(100); 
disPatientIdSource varchar(100);
BEGIN
	--delete the doublons
	EXECUTE ' delete  from ' || tempPidTableName ||  ' t1  where 
	oid > (select min(oid) from ' || tempPidTableName || ' t2 
		where t1.patient_map_id = t2.patient_map_id
		and t1.patient_map_id_source = t2.patient_map_id_source) ';
	LOCK TABLE  patient_mapping IN EXCLUSIVE MODE NOWAIT;
	select max(patient_num) into STRICT  maxPatientNum from patient_mapping ; 
	-- set max patient num to zero of the value is null
	if coalesce(maxPatientNum::text, '') = '' then 
		maxPatientNum := 0;
	end if;
	open distinctPidCur for EXECUTE 'SELECT distinct patient_id,patient_id_source from ' || tempPidTableName || '' ;
	loop
		FETCH distinctPidCur INTO disPatientId, disPatientIdSource;
		IF NOT FOUND THEN EXIT; 
	END IF; -- apply on distinctPidCur
	-- dbms_output.put_line(disPatientId);
	if  disPatientIdSource = 'HIVE'  THEN 
		begin
			--check if hive number exist, if so assign that number to reset of map_id's within that pid
			select patient_num into existingPatientNum from patient_mapping where patient_num = CAST(disPatientId AS numeric) and patient_ide_source = 'HIVE';
			EXCEPTION  when NO_DATA_FOUND THEN
				existingPatientNum := null;
		end;
		if (existingPatientNum IS NOT NULL AND existingPatientNum::text <> '') then 
			EXECUTE ' update ' || tempPidTableName ||' set patient_num = CAST(patient_id AS numeric), process_status_flag = ''P''
			where patient_id = $1 and not exists (select 1 from patient_mapping pm where pm.patient_ide = patient_map_id
				and pm.patient_ide_source = patient_map_id_source)' using disPatientId;
		else 
			-- generate new patient_num i.e. take max(patient_num) + 1 
			if maxPatientNum < CAST(disPatientId AS numeric) then 
				maxPatientNum := disPatientId;
			end if ;
			EXECUTE ' update ' || tempPidTableName ||' set patient_num = CAST(patient_id AS numeric), process_status_flag = ''P'' where 
			patient_id = $1 and patient_id_source = ''HIVE'' and not exists (select 1 from patient_mapping pm where pm.patient_ide = patient_map_id
				and pm.patient_ide_source = patient_map_id_source)' using disPatientId;
		end if;    
		-- test if record fectched
		-- dbms_output.put_line(' HIVE ');
	else 
		begin
			select patient_num into STRICT  existingPatientNum from patient_mapping where patient_ide = disPatientId and 
			patient_ide_source = disPatientIdSource ; 
			-- test if record fetched. 
			EXCEPTION
	WHEN NO_DATA_FOUND THEN
		existingPatientNum := null;
		end;
		if (existingPatientNum IS NOT NULL AND existingPatientNum::text <> '') then 
			EXECUTE ' update ' || tempPidTableName ||' set patient_num = CAST($1 AS numeric) , process_status_flag = ''P''
			where patient_id = $2 and not exists (select 1 from patient_mapping pm where pm.patient_ide = patient_map_id
				and pm.patient_ide_source = patient_map_id_source)' using  existingPatientNum,disPatientId;
		else 
			maxPatientNum := maxPatientNum + 1 ; 
			EXECUTE 'insert into ' || tempPidTableName ||' (
				patient_map_id
				,patient_map_id_source
				,patient_id
				,patient_id_source
				,patient_num
				,process_status_flag
				,patient_map_id_status
				,update_date
				,download_date
				,import_date
				,sourcesystem_cd) 
			values(
				$1
				,''HIVE''
				,$2
				,''HIVE''
				,$3
				,''P''
				,''A''
				,Now()
				,Now()
				,Now()
				,''edu.harvard.i2b2.crc''
			)' using maxPatientNum,maxPatientNum,maxPatientNum; 
			EXECUTE 'update ' || tempPidTableName ||' set patient_num =  $1 , process_status_flag = ''P'' 
			where patient_id = $2 and  not exists (select 1 from 
				patient_mapping pm where pm.patient_ide = patient_map_id
				and pm.patient_ide_source = patient_map_id_source)' using maxPatientNum, disPatientId  ;
		end if ;
		-- dbms_output.put_line(' NOT HIVE ');
	end if; 
	END LOOP;
	close distinctPidCur ;
	-- do the mapping update if the update date is old
EXECUTE ' UPDATE patient_mapping
SET 
patient_num = CAST(temp.patient_id AS numeric)
,patient_ide_status = temp.patient_map_id_status
,update_date = temp.update_date
,download_date  = temp.download_date
,import_date = Now()
,sourcesystem_cd  = temp.sourcesystem_cd
,upload_id = ' || upload_id ||'
FROM '|| tempPidTableName || '  temp
WHERE 
temp.patient_map_id = patient_mapping.patient_ide 
and temp.patient_map_id_source = patient_mapping.patient_ide_source
and temp.patient_id_source = ''HIVE''
and coalesce(temp.process_status_flag::text, '''') = ''''  
and coalesce(patient_mapping.update_date,to_date(''01-JAN-1900'',''DD-MON-YYYY'')) <= coalesce(temp.update_date,to_date(''01-JAN-1900'',''DD-MON-YYYY''))
';
	-- insert new mapping records i.e flagged P
	EXECUTE ' insert into patient_mapping (patient_ide,patient_ide_source,patient_ide_status,patient_num,update_date,download_date,import_date,sourcesystem_cd,upload_id,project_id)
	SELECT patient_map_id,patient_map_id_source,patient_map_id_status,patient_num,update_date,download_date,Now(),sourcesystem_cd,' || upload_id ||', ''@'' project_id from '|| tempPidTableName || ' 
	where process_status_flag = ''P'' ' ; 
	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;
	END;
	$_$;


ALTER FUNCTION i2b2crcdata.insert_pid_map_fromtemp(temppidtablename text, upload_id bigint, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: insert_provider_fromtemp(text, bigint); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.insert_provider_fromtemp(tempprovidertablename text, upload_id bigint, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN 
    --Delete duplicate rows with same encounter and patient combination
    EXECUTE 'DELETE FROM ' || tempProviderTableName || ' t1 WHERE oid > 
    (SELECT  min(oid) FROM ' || tempProviderTableName || ' t2
        WHERE t1.provider_id = t2.provider_id 
        AND t1.provider_path = t2.provider_path
    )';
    EXECUTE ' UPDATE provider_dimension  SET  
        provider_id =temp.provider_id
        , name_char = temp.name_char
        , provider_blob = temp.provider_blob
        , update_date=temp.update_date
        , download_date=temp.download_date
        , import_date=Now()
        , sourcesystem_cd=temp.sourcesystem_cd
        , upload_id = ' || upload_id || '
        FROM ' || tempProviderTableName || '  temp 
        WHERE 
        temp.provider_path = provider_dimension.provider_path and temp.update_date >= provider_dimension.update_date 
    AND EXISTS (select 1 from ' || tempProviderTableName || ' temp  where temp.provider_path = provider_dimension.provider_path 
        and temp.update_date >= provider_dimension.update_date) ';

    --Create new patient(patient_mapping) if temp table patient_ide does not exists 
    -- in patient_mapping table.
    EXECUTE 'insert into provider_dimension  (provider_id,provider_path,name_char,provider_blob,update_date,download_date,import_date,sourcesystem_cd,upload_id)
    SELECT  provider_id,provider_path, 
    name_char,provider_blob,
    update_date,download_date,
    Now(),sourcesystem_cd, ' || upload_id || '
    FROM ' || tempProviderTableName || '  temp
    WHERE NOT EXISTS (SELECT provider_id 
        FROM provider_dimension pd 
        WHERE pd.provider_path = temp.provider_path 
    )';
    EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;      
END;
$$;


ALTER FUNCTION i2b2crcdata.insert_provider_fromtemp(tempprovidertablename text, upload_id bigint, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: remove_temp_table(character varying); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.remove_temp_table(temptablename character varying, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$

DECLARE

BEGIN
    EXECUTE 'DROP TABLE ' || tempTableName|| ' CASCADE ';

EXCEPTION 
WHEN OTHERS THEN
    RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;      
END;
$$;


ALTER FUNCTION i2b2crcdata.remove_temp_table(temptablename character varying, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: sync_clear_concept_table(text, text, bigint); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.sync_clear_concept_table(tempconcepttablename text, backupconcepttablename text, uploadid bigint, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
 
interConceptTableName  varchar(400);

BEGIN 
        interConceptTableName := backupConceptTableName || '_inter';
                --Delete duplicate rows with same encounter and patient combination
        EXECUTE 'DELETE FROM ' || tempConceptTableName || ' t1 WHERE oid > 
                                           (SELECT  min(oid) FROM ' || tempConceptTableName || ' t2
                                             WHERE t1.concept_cd = t2.concept_cd 
                                            AND t1.concept_path = t2.concept_path
                                            )';
    EXECUTE 'create table ' ||  interConceptTableName || ' (
    CONCEPT_CD          varchar(50) NOT NULL,
        CONCEPT_PATH            varchar(700) NOT NULL,
        NAME_CHAR               varchar(2000) NULL,
        CONCEPT_BLOB        text NULL,
        UPDATE_DATE         timestamp NULL,
        DOWNLOAD_DATE       timestamp NULL,
        IMPORT_DATE         timestamp NULL,
        SOURCESYSTEM_CD     varchar(50) NULL,
        UPLOAD_ID               numeric(38,0) NULL,
    CONSTRAINT '|| interConceptTableName ||'_pk  PRIMARY KEY(CONCEPT_PATH)
         )';
    --Create new patient(patient_mapping) if temp table patient_ide does not exists 
        -- in patient_mapping table.
        EXECUTE 'insert into '|| interConceptTableName ||'  (concept_cd,concept_path,name_char,concept_blob,update_date,download_date,import_date,sourcesystem_cd,upload_id)
                            PERFORM  concept_cd, substring(concept_path from 1 for 700),
                        name_char,concept_blob,
                        update_date,download_date,
                        LOCALTIMESTAMP,sourcesystem_cd,
                         ' || uploadId || '  from ' || tempConceptTableName || '  temp ';
        --backup the concept_dimension table before creating a new one
        EXECUTE 'alter table concept_dimension rename to ' || backupConceptTableName  ||'' ;
        -- add index on upload_id 
    EXECUTE 'CREATE INDEX ' || interConceptTableName || '_uid_idx ON ' || interConceptTableName || '(UPLOAD_ID)';
    -- add index on upload_id 
    EXECUTE 'CREATE INDEX ' || interConceptTableName || '_cd_idx ON ' || interConceptTableName || '(concept_cd)';
    --backup the concept_dimension table before creating a new one
        EXECUTE 'alter table ' || interConceptTableName  || ' rename to concept_dimension' ;
EXCEPTION
        WHEN OTHERS THEN
                RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;      
END;
$$;


ALTER FUNCTION i2b2crcdata.sync_clear_concept_table(tempconcepttablename text, backupconcepttablename text, uploadid bigint, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: sync_clear_modifier_table(text, text, bigint); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.sync_clear_modifier_table(tempmodifiertablename text, backupmodifiertablename text, uploadid bigint, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
 
interModifierTableName  varchar(400);

BEGIN 
        interModifierTableName := backupModifierTableName || '_inter';
        --Delete duplicate rows with same modifier_path and modifier cd
        EXECUTE 'DELETE FROM ' || tempModifierTableName || ' t1 WHERE oid > 
                                           (SELECT  min(oid) FROM ' || tempModifierTableName || ' t2
                                             WHERE t1.modifier_cd = t2.modifier_cd 
                                            AND t1.modifier_path = t2.modifier_path
                                            )';
    EXECUTE 'create table ' ||  interModifierTableName || ' (
        MODIFIER_CD          varchar(50) NOT NULL,
        MODIFIER_PATH           varchar(700) NOT NULL,
        NAME_CHAR               varchar(2000) NULL,
        MODIFIER_BLOB        text NULL,
        UPDATE_DATE         timestamp NULL,
        DOWNLOAD_DATE       timestamp NULL,
        IMPORT_DATE         timestamp NULL,
        SOURCESYSTEM_CD     varchar(50) NULL,
        UPLOAD_ID               numeric(38,0) NULL,
    CONSTRAINT '|| interModifierTableName ||'_pk  PRIMARY KEY(MODIFIER_PATH)
         )';
    --Create new patient(patient_mapping) if temp table patient_ide does not exists 
        -- in patient_mapping table.
        EXECUTE 'insert into '|| interModifierTableName ||'  (modifier_cd,modifier_path,name_char,modifier_blob,update_date,download_date,import_date,sourcesystem_cd,upload_id)
                            PERFORM  modifier_cd, substring(modifier_path from 1 for 700),
                        name_char,modifier_blob,
                        update_date,download_date,
                        LOCALTIMESTAMP,sourcesystem_cd,
                         ' || uploadId || '  from ' || tempModifierTableName || '  temp ';
        --backup the modifier_dimension table before creating a new one
        EXECUTE 'alter table modifier_dimension rename to ' || backupModifierTableName  ||'' ;
        -- add index on upload_id 
    EXECUTE 'CREATE INDEX ' || interModifierTableName || '_uid_idx ON ' || interModifierTableName || '(UPLOAD_ID)';
    -- add index on upload_id 
    EXECUTE 'CREATE INDEX ' || interModifierTableName || '_cd_idx ON ' || interModifierTableName || '(modifier_cd)';
       --backup the modifier_dimension table before creating a new one
        EXECUTE 'alter table ' || interModifierTableName  || ' rename to modifier_dimension' ;
EXCEPTION
        WHEN OTHERS THEN
                RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;      
END;
$$;


ALTER FUNCTION i2b2crcdata.sync_clear_modifier_table(tempmodifiertablename text, backupmodifiertablename text, uploadid bigint, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: sync_clear_provider_table(text, text, bigint); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.sync_clear_provider_table(tempprovidertablename text, backupprovidertablename text, uploadid bigint, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
 
interProviderTableName  varchar(400);

BEGIN 
        interProviderTableName := backupProviderTableName || '_inter';
                --Delete duplicate rows with same encounter and patient combination
        EXECUTE 'DELETE FROM ' || tempProviderTableName || ' t1 WHERE oid > 
                                           (SELECT  min(oid) FROM ' || tempProviderTableName || ' t2
                                             WHERE t1.provider_id = t2.provider_id 
                                            AND t1.provider_path = t2.provider_path
                                            )';
    EXECUTE 'create table ' ||  interProviderTableName || ' (
    PROVIDER_ID         varchar(50) NOT NULL,
        PROVIDER_PATH       varchar(700) NOT NULL,
        NAME_CHAR               varchar(850) NULL,
        PROVIDER_BLOB       text NULL,
        UPDATE_DATE             timestamp NULL,
        DOWNLOAD_DATE       timestamp NULL,
        IMPORT_DATE         timestamp NULL,
        SOURCESYSTEM_CD     varchar(50) NULL,
        UPLOAD_ID               numeric(38,0) NULL ,
    CONSTRAINT  ' || interProviderTableName || '_pk PRIMARY KEY(PROVIDER_PATH,provider_id)
         )';
    --Create new patient(patient_mapping) if temp table patient_ide does not exists 
        -- in patient_mapping table.
        EXECUTE 'insert into ' ||  interProviderTableName || ' (provider_id,provider_path,name_char,provider_blob,update_date,download_date,import_date,sourcesystem_cd,upload_id)
                            PERFORM  provider_id,provider_path, 
                        name_char,provider_blob,
                        update_date,download_date,
                        LOCALTIMESTAMP,sourcesystem_cd, ' || uploadId || '
                             from ' || tempProviderTableName || '  temp ';
        --backup the concept_dimension table before creating a new one
        EXECUTE 'alter table provider_dimension rename to ' || backupProviderTableName  ||'' ;
        -- add index on provider_id, name_char 
    EXECUTE 'CREATE INDEX ' || interProviderTableName || '_id_idx ON ' || interProviderTableName  || '(Provider_Id,name_char)';
    EXECUTE 'CREATE INDEX ' || interProviderTableName || '_uid_idx ON ' || interProviderTableName  || '(UPLOAD_ID)';
        --backup the concept_dimension table before creating a new one
        EXECUTE 'alter table ' || interProviderTableName  || ' rename to provider_dimension' ;
EXCEPTION
        WHEN OTHERS THEN
                RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;      
END;
$$;


ALTER FUNCTION i2b2crcdata.sync_clear_provider_table(tempprovidertablename text, backupprovidertablename text, uploadid bigint, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: update_observation_fact(text, bigint, bigint); Type: FUNCTION; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE FUNCTION i2b2crcdata.update_observation_fact(upload_temptable_name text, upload_id bigint, appendflag bigint, OUT errormsg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- appendFlag = 0 -> remove all and then insert
    -- appendFlag <> 0 -> do update, then insert what have not been updated    

    --Delete duplicate records(encounter_ide,patient_ide,concept_cd,start_date,modifier_cd,provider_id)
    EXECUTE 'DELETE FROM ' || upload_temptable_name ||'  t1 
    WHERE oid > (select min(oid) FROM ' || upload_temptable_name ||' t2 
        WHERE t1.encounter_id = t2.encounter_id  
        AND
        t1.encounter_id_source = t2.encounter_id_source
        AND
        t1.patient_id = t2.patient_id 
        AND 
        t1.patient_id_source = t2.patient_id_source
        AND 
        t1.concept_cd = t2.concept_cd
        AND 
        t1.start_date = t2.start_date
        AND 
        coalesce(t1.modifier_cd,''xyz'') = coalesce(t2.modifier_cd,''xyz'')
        AND 
        t1.instance_num = t2.instance_num
        AND 
        t1.provider_id = t2.provider_id)';
    --Delete records having null in start_date
    EXECUTE 'DELETE FROM ' || upload_temptable_name ||'  t1           
    WHERE coalesce(t1.start_date::text, '''') = '''' 
    ';
    --One time lookup on encounter_ide to get encounter_num 
    EXECUTE 'UPDATE ' ||  upload_temptable_name
    || ' SET encounter_num = (SELECT distinct em.encounter_num
        FROM encounter_mapping em
        WHERE em.encounter_ide = ' || upload_temptable_name||'.encounter_id
        AND em.encounter_ide_source = '|| upload_temptable_name||'.encounter_id_source
        and em.project_id=''@'' and em.patient_ide = ' || upload_temptable_name||'.patient_id
        and em.patient_ide_source = '|| upload_temptable_name||'.patient_id_source
    )
    WHERE EXISTS (SELECT distinct em.encounter_num
        FROM encounter_mapping em
        WHERE em.encounter_ide = '|| upload_temptable_name||'.encounter_id
        AND em.encounter_ide_source = '||upload_temptable_name||'.encounter_id_source
                     and em.project_id=''@'' and em.patient_ide = ' || upload_temptable_name||'.patient_id
                     and em.patient_ide_source = '|| upload_temptable_name||'.patient_id_source)';		     
             
    --One time lookup on patient_ide to get patient_num 
    EXECUTE 'UPDATE ' ||  upload_temptable_name
    || ' SET patient_num = (SELECT distinct pm.patient_num
        FROM patient_mapping pm
        WHERE pm.patient_ide = '|| upload_temptable_name||'.patient_id
        AND pm.patient_ide_source = '|| upload_temptable_name||'.patient_id_source
                     and pm.project_id=''@''

    )
    WHERE EXISTS (SELECT distinct pm.patient_num 
        FROM patient_mapping pm
        WHERE pm.patient_ide = '|| upload_temptable_name||'.patient_id
        AND pm.patient_ide_source = '||upload_temptable_name||'.patient_id_source              
                     and pm.project_id=''@'')';		     

    IF (appendFlag = 0) THEN
        --Archive records which are to be deleted in observation_fact table
        EXECUTE 'INSERT INTO  archive_observation_fact 
        SELECT obsfact.*, ' || upload_id ||'
        FROM observation_fact obsfact
        WHERE obsfact.encounter_num IN 
        (SELECT temp_obsfact.encounter_num
            FROM  ' ||upload_temptable_name ||' temp_obsfact
            GROUP BY temp_obsfact.encounter_num  
        )';
        --Delete above archived row FROM observation_fact
        EXECUTE 'DELETE  
        FROM observation_fact 
        WHERE EXISTS (
            SELECT archive.encounter_num
            FROM archive_observation_fact  archive
            WHERE archive.archive_upload_id = '||upload_id ||'
            AND archive.encounter_num=observation_fact.encounter_num
            AND archive.concept_cd = observation_fact.concept_cd
            AND archive.start_date = observation_fact.start_date
        )';
END IF;
-- if the append is true, then do the update else do insert all
IF (appendFlag <> 0) THEN -- update
    EXECUTE ' 
    UPDATE observation_fact f    
    SET valtype_cd = temp.valtype_cd ,
    tval_char=temp.tval_char, 
    nval_num = temp.nval_num,
    valueflag_cd=temp.valueflag_cd,
    quantity_num=temp.quantity_num,
    confidence_num=temp.confidence_num,
    observation_blob =temp.observation_blob,
    units_cd=temp.units_cd,
    end_date=temp.end_date,
    location_cd =temp.location_cd,
    update_date=temp.update_date ,
    download_date =temp.download_date,
    import_date=temp.import_date,
    sourcesystem_cd =temp.sourcesystem_cd,
    upload_id = temp.upload_id 
    FROM ' || upload_temptable_name ||' temp
    WHERE 
    temp.patient_num is not null 
    and temp.encounter_num is not null 
    and temp.encounter_num = f.encounter_num 
    and temp.patient_num = f.patient_num
    and temp.concept_cd = f.concept_cd
    and temp.start_date = f.start_date
    and temp.provider_id = f.provider_id
    and temp.modifier_cd = f.modifier_cd 
    and temp.instance_num = f.instance_num
    and coalesce(f.update_date,to_date(''01-JAN-1900'',''DD-MON-YYYY'')) <= coalesce(temp.update_date,to_date(''01-JAN-1900'',''DD-MON-YYYY''))';

    EXECUTE  'DELETE FROM ' || upload_temptable_name ||' temp WHERE EXISTS (SELECT 1 
        FROM observation_fact f 
        WHERE temp.patient_num is not null 
        and temp.encounter_num is not null 
        and temp.encounter_num = f.encounter_num 
        and temp.patient_num = f.patient_num
        and temp.concept_cd = f.concept_cd
        and temp.start_date = f.start_date
        and temp.provider_id = f.provider_id
        and temp.modifier_cd = f.modifier_cd 
        and temp.instance_num = f.instance_num
    )';

END IF;
--Transfer all rows FROM temp_obsfact to observation_fact
EXECUTE 'INSERT INTO observation_fact(
    encounter_num
    ,concept_cd
    , patient_num
    ,provider_id
    , start_date
    ,modifier_cd
    ,instance_num
    ,valtype_cd
    ,tval_char
    ,nval_num
    ,valueflag_cd
    ,quantity_num
    ,confidence_num
    ,observation_blob
    ,units_cd
    ,end_date
    ,location_cd
    , update_date
    ,download_date
    ,import_date
    ,sourcesystem_cd
    ,upload_id)
SELECT encounter_num
,concept_cd
, patient_num
,provider_id
, start_date
,modifier_cd
,instance_num
,valtype_cd
,tval_char
,nval_num
,valueflag_cd
,quantity_num
,confidence_num
,observation_blob
,units_cd
,end_date
,location_cd
, update_date
,download_date
,Now()
,sourcesystem_cd
,temp.upload_id 
FROM ' || upload_temptable_name ||' temp
WHERE (temp.patient_num IS NOT NULL AND temp.patient_num::text <> '''') AND  (temp.encounter_num IS NOT NULL AND temp.encounter_num::text <> '''')';


EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'An error was encountered - % -ERROR- %',SQLSTATE,SQLERRM;      
END;
$$;


ALTER FUNCTION i2b2crcdata.update_observation_fact(upload_temptable_name text, upload_id bigint, appendflag bigint, OUT errormsg text) OWNER TO i2b2crcdata;

--
-- Name: pat_count_dimensions(character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE FUNCTION i2b2metadata.pat_count_dimensions(metadatatable character varying, schemaname character varying, observationtable character varying, facttablecolumn character varying, tablename character varying, columnname character varying) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare 
        -- select PAT_COUNT_DIMENSIONS( 'I2B2' ,'public' , 'observation_fact' ,  'concept_cd', 'concept_dimension', 'concept_path'  )
    v_sqlstr text;
    v_num integer;
    curRecord RECORD;
    v_startime timestamp;
    v_duration text = '';
BEGIN
    raise info 'At %, running PAT_COUNT_DIMENSIONS(''%'')',clock_timestamp(), metadataTable;
    v_startime := clock_timestamp();

    DISCARD TEMP;
    -- Modify this query to select a list of all your ontology paths and basecodes.

    v_sqlstr := 'create temp table dimCountOnt AS '
             || ' select c_fullname, c_basecode, c_hlevel '
             || ' from ' || metadataTable  
             || ' where lower(c_facttablecolumn) = '''||facttablecolumn||''' '
             || ' and lower(c_tablename) = '''|| tablename || ''' '
             || ' and lower(c_columnname) = '''|| columnname || ''' '
             || ' and lower(c_synonym_cd) = ''n'' '
             || ' and lower(c_columndatatype) = ''t'' '
             || ' and lower(c_operator) = ''like'' '
             || ' and m_applied_path = ''@'' '
		     || ' and coalesce(c_fullname, '''') <> '''' '
		     || ' and (c_visualattributes not like ''L%'' or  c_basecode in (select distinct concept_cd from observation_fact)) ';
		-- NEW: Sparsify the working ontology by eliminating leaves with no data. HUGE win in ACT meds ontology (10x speedup).
        -- From 1.47M entries to 300k entries!
           
    raise info 'SQL: %',v_sqlstr;
    execute v_sqlstr;

    create index dimCountOntA on dimCountOnt using spgist (c_fullname);
    CREATE INDEX dimCountOntB ON dimCountOnt(c_fullname text_pattern_ops);

    create temp table dimOntWithFolders AS
        select distinct p1.c_fullname, p1.c_basecode
        from dimCountOnt p1
        where 1=0;
        
    CREATE INDEX dimOntWithFoldersIndex ON dimOntWithFolders using btree(c_basecode);


For curRecord IN 
		select c_fullname,c_table_name from table_access 
    LOOP 
if metadataTable = curRecord.c_table_name then
--v_sqlstr := 'insert into dimOntWithFolders select distinct  c_fullname , c_basecode  from  provider_ont where c_fullname like ''' || replace(curRecord.c_fullname,'\','\\') || '%'' ';

--v_sqlstr := 'insert into dimOntWithFolders '
--       || '   select distinct p1.c_fullname, p2.c_basecode '
--       || '   from dimCountOnt p1 '
--       || '   inner join dimCountOnt p2 '
--       || '     on p2.c_fullname like p1.c_fullname || ''%''  '
--       || '     where p2.c_fullname like  ''' || replace(curRecord.c_fullname,'\','\\') || '%'' '
--       || '       and p1.c_fullname like  ''' || replace(curRecord.c_fullname,'\','\\') || '%'' ';


-- Jeff Green's version
v_sqlstr := 'with recursive concepts (c_fullname, c_hlevel, c_basecode) as ('
	|| ' select c_fullname, c_hlevel, c_basecode '
	|| '  from dimCountOnt '
	|| '  where c_fullname like ''' || replace(curRecord.c_fullname,'\','\\') || '%'' '
	|| ' union all ' 
	|| ' select cast( '
	|| '  	left(c_fullname, length(c_fullname)-position(''\'' in right(reverse(c_fullname), length(c_fullname)-1))) '
	|| '	   	as varchar(700) '
	|| '	) c_fullname, ' 
	|| ' c_hlevel-1 c_hlevel, c_basecode '
	|| ' from concepts '
	|| ' where concepts.c_hlevel>0 '
	|| ' ) '
|| ' insert into dimOntWithFolders '
|| ' select distinct c_fullname, c_basecode '
|| '  from concepts '
|| '  where c_fullname like ''' || replace(curRecord.c_fullname,'\','\\') || '%'' '
|| '  order by c_fullname, c_basecode ';

    raise info 'SQL_dimOntWithFolders: %',v_sqlstr;
	execute v_sqlstr;

	--raise notice 'At %, collected concepts for % %',clock_timestamp(),curRecord.c_table_name,curRecord.c_fullname;
	v_duration := clock_timestamp()-v_startime;
	raise info '(BENCH) %,collected_concepts,%',curRecord,v_duration;
	v_startime := clock_timestamp();

 end if;

    END LOOP;

    -- Too slow version
    --v_sqlstr := ' create temp table finalDimCounts AS '
    --    || ' select p1.c_fullname, count(distinct patient_num) as num_patients '
    --    || ' from dimOntWithFolders p1 '
    --    || ' left join ' || schemaName ||'.'|| observationtable ||  '  o '
    --    || '     on p1.c_basecode = o.' || facttablecolumn  --provider id
    --    || '     and coalesce(p1.c_basecode, '''') <> '''' '
    --    || ' group by p1.c_fullname';
    
    -- 10-20x faster version (based on MSSQL optimizations) 
    
    -- Assign a number to each path and use this for the join to the fact table!
    create temp table Path2Num as
    select c_fullname, row_number() over (order by c_fullname) path_num
        from (
            select distinct c_fullname c_fullname
            from dimOntWithFolders
            where c_fullname is not null and c_fullname<>''
        ) t;
    
    alter table Path2Num add primary key (c_fullname);
    
    create temp table ConceptPath as
    select path_num,c_basecode from Path2Num n inner join dimontwithfolders o on o.c_fullname=n.c_fullname
    where o.c_fullname is not null and c_basecode is not null;
    
    alter table ConceptPath add primary key (c_basecode, path_num);
    
    create temp table PathCounts as
    select p1.path_num, count(distinct patient_num) as num_patients  from ConceptPath p1  left join public.observation_fact  o      on p1.c_basecode = o.concept_cd     and coalesce(p1.c_basecode, '') <> ''  group by p1.path_num;
    
    alter table PathCounts add primary key (path_num);
    
    create temp table finalCountsbyConcept as
    select p.c_fullname, c.num_patients num_patients 
        from PathCounts c
          inner join Path2Num p
           on p.path_num=c.path_num
        order by p.c_fullname;


    --raise notice 'At %, done counting.',clock_timestamp();
	v_duration := clock_timestamp()-v_startime;
	raise info '(BENCH) %,counted_concepts,%',curRecord,v_duration;
	v_startime := clock_timestamp();

    create index on finalCountsbyConcept using btree (c_fullname);

    v_sqlstr := ' update ' || metadataTable || ' a set c_totalnum=b.num_patients '
             || ' from finalCountsbyConcept b '
             || ' where a.c_fullname=b.c_fullname '
            || ' and lower(a.c_facttablecolumn)= ''' || facttablecolumn || ''' '
		    || ' and lower(a.c_tablename) = ''' || tablename || ''' '
		    || ' and lower(a.c_columnname) = ''' || columnname || ''' ';
    select count(*) into v_num from finalCountsByConcept where num_patients is not null and num_patients <> 0;
    raise info 'At %, updating c_totalnum in % %',clock_timestamp(), metadataTable, v_num;
    
	execute v_sqlstr;

    discard temp;
END; 
$$;


ALTER FUNCTION i2b2metadata.pat_count_dimensions(metadatatable character varying, schemaname character varying, observationtable character varying, facttablecolumn character varying, tablename character varying, columnname character varying) OWNER TO i2b2metadata;

--
-- Name: pat_count_visits(character varying, character varying); Type: FUNCTION; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE FUNCTION i2b2metadata.pat_count_visits(tabname character varying, tableschema character varying) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare 
    v_sqlstr text;
    -- using cursor defined withing FOR RECORD IN QUERY loop below.
    curRecord RECORD;
    v_num integer;
BEGIN
    --display count and timing information to the user
  
    --using all temporary tables instead of creating and dropping tables
    DISCARD TEMP;
    --checking each text fields for forced lowercase values since DB defaults to case sensitive 
	v_sqlstr = 'create temp table ontPatVisitDims as '
          ||    ' select c_fullname'
          ||          ', c_basecode'
          ||          ', c_facttablecolumn'
          ||          ', c_tablename'
          ||          ', c_columnname'
          ||          ', c_operator'
          ||          ', c_dimcode'
          ||          ', null::integer as numpats'
          ||      ' from ' || tabname
          ||      ' where  m_applied_path = ''@'''
          ||        ' and lower(c_tablename) in (''patient_dimension'', ''visit_dimension'') ';

    /*
     * THE ORIGINAL WUSM implementation did not have the column "visit_dimension.location_zip" in 
     *     ||        ' and lower(c_columnname) not in (''location_zip'') '; --ignoring this often occuring column that we know is not in WUSM schema
     */

    execute v_sqlstr;

    -- rather than creating cursor and fetching rows into local variables, instead using record variable type to 
    -- access each element of the current row of the cursor
	For curRecord IN 
		select c_fullname, c_facttablecolumn, c_tablename, c_columnname, c_operator, c_dimcode from ontPatVisitDims
    LOOP 
 --raise info 'At %: Running: %',curRecord.c_tablename, curRecord.c_columnname;
        -- check first to determine if current columns of current table actually exist in the schema
   --     if exists(select 1 from information_schema.columns 
   --               where table_catalog = current_catalog 
   --                 and table_schema = ' || tableschema || '
   --                 and table_name = lower(curRecord.c_tablename)
   --                 and column_name = lower(curRecord.c_columnname)
   --              ) then 

            -- simplified query to directly query distinct patient_num instead of querying list of patien_num to feed into outer query for the same
            -- result.  New style runs in approximately half the time as tested with all patients with a particular sex_cd value.  Since all rows 
            -- Since c_facttablecolumn is ALWAYS populated with 'patient_num' for all rows accessed by this function the change to the function is 
            -- worthwhile.  Only in rare cases if changes to the ontology tables are made would the original query be needed, but only where 
            -- c_facttablecolumn would not be 'patient_num AND the values saved in that column in the dimension table are shared between patients that 
            -- don't otherwise have the same ontology would the original method return different results.  It is believed that those results would be 
            -- inaccurate since they would reflect the number of patients who have XXX like patients with this ontology rather than the number of patients
            -- with that ontology. 
            v_sqlstr := 'update ontPatVisitDims '
                     || ' set numpats =  ( '                     
                     ||     ' select count(distinct(patient_num)) '
                     ||     ' from ' || tableschema || '.' || curRecord.c_tablename 
                     --||     ' where ' || curRecord.c_facttablecolumn
                     --||     ' in ( '
                     --||         ' select ' || curRecord.c_facttablecolumn 
                     --||         ' from ' || tableschema || '.' || curRecord.c_tablename 
                     ||         ' where '|| curRecord.c_columnname || ' '  ;
--Running: update ontPatVisitDims  set numpats =  (  select count(distinct(patient_num))  from public.PATIENT_DIMENSION where RACE_CD = es ) 
            CASE 
            WHEN lower(curRecord.c_columnname) = 'birth_date' 
                 and lower(curRecord.c_tablename) = 'patient_dimension'
                 and lower(curRecord.c_dimcode) like '%not recorded%' then 
                    -- adding specific change of " WHERE patient_dimension.birth_date in ('not_recorded') " to " WHERE patient_dimension.birth_date IS NULL " 
                    -- since IS NULL syntax is not supported in the ontology tables, but the birth_date column is a timestamp datatype and can be null, but cannot be
                    -- the character string 'not recorded'
                    v_sqlstr := v_sqlstr || ' is null';
            WHEN lower(curRecord.c_operator) = 'like' then 
                -- escaping escape characters and double quotes.  The additon of '\' to '\\' is needed in Postgres. Alternatively, a custom escape character
                -- could be listed in the query if it is known for certain that that character will never be found in any c_dimcode value accessed by this 
                -- function
                v_sqlstr := v_sqlstr || curRecord.c_operator  || ' ' || '''' || replace(replace(curRecord.c_dimcode,'\','\\'),'''','''''') || '%''' ;
           WHEN lower(curRecord.c_operator) = 'in' then 
                v_sqlstr := v_sqlstr || curRecord.c_operator  || ' ' ||  '(' || curRecord.c_dimcode || ')';
            WHEN lower(curRecord.c_operator) = '=' then 
           --     v_sqlstr := v_sqlstr || curRecord.c_operator  || ' ' ||  replace(curRecord.c_dimcode,'''','''''') ;
                v_sqlstr := v_sqlstr || curRecord.c_operator  || ' ''' ||  replace(curRecord.c_dimcode,'''','''''') || '''';
            ELSE 
                -- A mistake in WUSM data existed, requiring special handling in this function.  
                -- The original note is listed next for reference purposes only and the IF THEN 
                -- ELSE block that was needed has been commented out since the original mistake 
                -- in the ontology tables has been corrected.

                /* ORIGINAL NOTE AND CODE
                 *   -- a mistake in WUSM data has this c_dimcode incorrectly listed.  It is being handled in this function until other testing and approvals
                 *   -- are conducted to allow for the correction of this value in the ontology table.
                 *   if curRecord.c_dimcode = 'current_date - interval ''85 year''85 year''' then 
                 *       v_sqlstr := v_sqlstr || curRecord.c_operator  || ' ' || 'current_date - interval ''85 year''';
                 *   else
                 */
                        v_sqlstr := v_sqlstr || curRecord.c_operator  || ' ' || curRecord.c_dimcode;
                /* 
                 *   end if;
                 */
            END CASE;
            
            v_sqlstr := v_sqlstr -- || ' ) ' -- in
                     || ' ) ' -- set
                     || ' where c_fullname = ' || '''' || curRecord.c_fullname || '''' 
                     || ' and numpats is null';

    
			begin
            	execute v_sqlstr;
			EXCEPTION WHEN OTHERS THEN
				raise info 'At %: EROR: %',clock_timestamp()e, v_sqlstr;
		      -- keep looping
   			END;
		--else
            -- do nothing since we do not have the column in our schema
     --   end if;
    END LOOP;

	v_sqlstr := 'update ' || tabname || ' a set c_totalnum=b.numpats '
             || ' from ontPatVisitDims b '
             || ' where a.c_fullname=b.c_fullname ';

    raise info 'At %: Running: %',clock_timestamp()e, v_sqlstr;
 
    --display count and timing information to the user
    select count(*) into v_num from ontPatVisitDims where numpats is not null and numpats <> 0;
    raise info 'At %, updating c_totalnum in % for % records',clock_timestamp(), tabname, v_num;
             
	execute v_sqlstr;
    discard temp;
END;
$$;


ALTER FUNCTION i2b2metadata.pat_count_visits(tabname character varying, tableschema character varying) OWNER TO i2b2metadata;

--
-- Name: runtotalnum(text, text); Type: FUNCTION; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE FUNCTION i2b2metadata.runtotalnum(observationtable text, schemaname text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE 
    curRecord RECORD;
    v_sqlstring text = '';
    v_union text = '';
    v_numpats integer;
    v_startime timestamp;
    v_duration text = '';
begin
    raise info 'At %, running RunTotalnum()',clock_timestamp();
    v_startime := clock_timestamp();

    for curRecord IN 
        select distinct c_table_name as sqltext
        from TABLE_ACCESS 
        where c_visualattributes like '%A%' 
    LOOP 
        raise info 'At %: Running: %',clock_timestamp(), curRecord.sqltext;

        v_sqlstring := 'select  PAT_COUNT_VISITS( '''||curRecord.sqltext||''' ,'''||schemaName||'''   )';
		execute v_sqlstring;
		v_duration := clock_timestamp()-v_startime;
		raise info '(BENCH) %,PAT_COUNT_VISITS,%',curRecord,v_duration;
		v_startime := clock_timestamp();
		
        v_sqlstring := 'select PAT_COUNT_DIMENSIONS( '''||curRecord.sqltext||''' ,'''||schemaName||''' , '''||observationTable||''' ,  ''concept_cd'', ''concept_dimension'', ''concept_path''  )';
		execute v_sqlstring;
        v_duration :=  clock_timestamp()-v_startime;
		raise info '(BENCH) %,PAT_COUNT_concept_dimension,%',curRecord,v_duration;
		v_startime := clock_timestamp();
        
        v_sqlstring := 'select PAT_COUNT_DIMENSIONS( '''||curRecord.sqltext||''' ,'''||schemaName||''' , '''||observationTable||''' ,  ''provider_id'', ''provider_dimension'', ''provider_path''  )';
		execute v_sqlstring;
		v_duration := clock_timestamp()-v_startime;
		raise info '(BENCH) %,PAT_COUNT_provider_dimension,%',curRecord,v_duration;
		v_startime := clock_timestamp();
		
        v_sqlstring := 'select PAT_COUNT_DIMENSIONS( '''||curRecord.sqltext||''' ,'''||schemaName||''' , '''||observationTable||''' ,  ''modifier_cd'', ''modifier_dimension'', ''modifier_path''  )';
		execute v_sqlstring;
		v_duration := clock_timestamp()-v_startime;
		raise info '(BENCH) %,PAT_COUNT_modifier_dimension,%',curRecord,v_duration;
		v_startime := clock_timestamp();

    END LOOP;
end; 
$$;


ALTER FUNCTION i2b2metadata.runtotalnum(observationtable text, schemaname text) OWNER TO i2b2metadata;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: archive_observation_fact; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.archive_observation_fact (
    encounter_num integer,
    patient_num integer,
    concept_cd character varying(50),
    provider_id character varying(50),
    start_date timestamp without time zone,
    modifier_cd character varying(100),
    instance_num integer,
    valtype_cd character varying(50),
    tval_char character varying(255),
    nval_num numeric(18,5),
    valueflag_cd character varying(50),
    quantity_num numeric(18,5),
    units_cd character varying(50),
    end_date timestamp without time zone,
    location_cd character varying(50),
    observation_blob text,
    confidence_num numeric(18,5),
    update_date timestamp without time zone,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    upload_id integer,
    text_search_index integer,
    archive_upload_id integer
);


ALTER TABLE i2b2crcdata.archive_observation_fact OWNER TO i2b2crcdata;

--
-- Name: code_lookup; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.code_lookup (
    table_cd character varying(100) NOT NULL,
    column_cd character varying(100) NOT NULL,
    code_cd character varying(50) NOT NULL,
    name_char character varying(650),
    lookup_blob text,
    upload_date timestamp without time zone,
    update_date timestamp without time zone,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    upload_id integer
);


ALTER TABLE i2b2crcdata.code_lookup OWNER TO i2b2crcdata;

--
-- Name: concept_dimension; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.concept_dimension (
    concept_path character varying(700) NOT NULL,
    concept_cd character varying(50),
    name_char character varying(2000),
    concept_blob text,
    update_date timestamp without time zone,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    upload_id integer
);


ALTER TABLE i2b2crcdata.concept_dimension OWNER TO i2b2crcdata;

--
-- Name: datamart_report; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.datamart_report (
    total_patient integer,
    total_observationfact integer,
    total_event integer,
    report_date timestamp without time zone
);


ALTER TABLE i2b2crcdata.datamart_report OWNER TO i2b2crcdata;

--
-- Name: encounter_mapping; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.encounter_mapping (
    encounter_ide character varying(200) NOT NULL,
    encounter_ide_source character varying(50) NOT NULL,
    project_id character varying(50) NOT NULL,
    encounter_num integer NOT NULL,
    patient_ide character varying(200) NOT NULL,
    patient_ide_source character varying(50) NOT NULL,
    encounter_ide_status character varying(50),
    upload_date timestamp without time zone,
    update_date timestamp without time zone,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    upload_id integer
);


ALTER TABLE i2b2crcdata.encounter_mapping OWNER TO i2b2crcdata;

--
-- Name: modifier_dimension; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.modifier_dimension (
    modifier_path character varying(700) NOT NULL,
    modifier_cd character varying(50),
    name_char character varying(2000),
    modifier_blob text,
    update_date timestamp without time zone,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    upload_id integer
);


ALTER TABLE i2b2crcdata.modifier_dimension OWNER TO i2b2crcdata;

--
-- Name: observation_fact; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.observation_fact (
    encounter_num integer NOT NULL,
    patient_num integer NOT NULL,
    concept_cd character varying(50) NOT NULL,
    provider_id character varying(50) NOT NULL,
    start_date timestamp without time zone NOT NULL,
    modifier_cd character varying(100) DEFAULT '@'::character varying NOT NULL,
    instance_num integer DEFAULT 1 NOT NULL,
    valtype_cd character varying(50),
    tval_char character varying(255),
    nval_num numeric(18,5),
    valueflag_cd character varying(50),
    quantity_num numeric(18,5),
    units_cd character varying(50),
    end_date timestamp without time zone,
    location_cd character varying(50),
    observation_blob text,
    confidence_num numeric(18,5),
    update_date timestamp without time zone,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    upload_id integer,
    text_search_index integer NOT NULL
);


ALTER TABLE i2b2crcdata.observation_fact OWNER TO i2b2crcdata;

--
-- Name: observation_fact_text_search_index_seq; Type: SEQUENCE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE SEQUENCE i2b2crcdata.observation_fact_text_search_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2crcdata.observation_fact_text_search_index_seq OWNER TO i2b2crcdata;

--
-- Name: observation_fact_text_search_index_seq; Type: SEQUENCE OWNED BY; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER SEQUENCE i2b2crcdata.observation_fact_text_search_index_seq OWNED BY i2b2crcdata.observation_fact.text_search_index;


--
-- Name: patient_dimension; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.patient_dimension (
    patient_num integer NOT NULL,
    vital_status_cd character varying(50),
    birth_date timestamp without time zone,
    death_date timestamp without time zone,
    sex_cd character varying(50),
    age_in_years_num integer,
    language_cd character varying(50),
    race_cd character varying(50),
    marital_status_cd character varying(50),
    religion_cd character varying(50),
    zip_cd character varying(10),
    statecityzip_path character varying(700),
    income_cd character varying(50),
    patient_blob text,
    update_date timestamp without time zone,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    upload_id integer
);


ALTER TABLE i2b2crcdata.patient_dimension OWNER TO i2b2crcdata;

--
-- Name: patient_mapping; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.patient_mapping (
    patient_ide character varying(200) NOT NULL,
    patient_ide_source character varying(50) NOT NULL,
    patient_num integer NOT NULL,
    patient_ide_status character varying(50),
    project_id character varying(50) NOT NULL,
    upload_date timestamp without time zone,
    update_date timestamp without time zone,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    upload_id integer
);


ALTER TABLE i2b2crcdata.patient_mapping OWNER TO i2b2crcdata;

--
-- Name: provider_dimension; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.provider_dimension (
    provider_id character varying(50) NOT NULL,
    provider_path character varying(700) NOT NULL,
    name_char character varying(850),
    provider_blob text,
    update_date timestamp without time zone,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    upload_id integer
);


ALTER TABLE i2b2crcdata.provider_dimension OWNER TO i2b2crcdata;

--
-- Name: qt_analysis_plugin; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.qt_analysis_plugin (
    plugin_id integer NOT NULL,
    plugin_name character varying(2000),
    description character varying(2000),
    version_cd character varying(50),
    parameter_info text,
    parameter_info_xsd text,
    command_line text,
    working_folder text,
    commandoption_cd text,
    plugin_icon text,
    status_cd character varying(50),
    user_id character varying(50),
    group_id character varying(50),
    create_date timestamp without time zone,
    update_date timestamp without time zone
);


ALTER TABLE i2b2crcdata.qt_analysis_plugin OWNER TO i2b2crcdata;

--
-- Name: qt_analysis_plugin_result_type; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.qt_analysis_plugin_result_type (
    plugin_id integer NOT NULL,
    result_type_id integer NOT NULL
);


ALTER TABLE i2b2crcdata.qt_analysis_plugin_result_type OWNER TO i2b2crcdata;

--
-- Name: qt_breakdown_path; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.qt_breakdown_path (
    name character varying(100),
    value character varying(2000),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    user_id character varying(50)
);


ALTER TABLE i2b2crcdata.qt_breakdown_path OWNER TO i2b2crcdata;

--
-- Name: qt_patient_enc_collection; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.qt_patient_enc_collection (
    patient_enc_coll_id integer NOT NULL,
    result_instance_id integer,
    set_index integer,
    patient_num integer,
    encounter_num integer
);


ALTER TABLE i2b2crcdata.qt_patient_enc_collection OWNER TO i2b2crcdata;

--
-- Name: qt_patient_enc_collection_patient_enc_coll_id_seq; Type: SEQUENCE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE SEQUENCE i2b2crcdata.qt_patient_enc_collection_patient_enc_coll_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2crcdata.qt_patient_enc_collection_patient_enc_coll_id_seq OWNER TO i2b2crcdata;

--
-- Name: qt_patient_enc_collection_patient_enc_coll_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER SEQUENCE i2b2crcdata.qt_patient_enc_collection_patient_enc_coll_id_seq OWNED BY i2b2crcdata.qt_patient_enc_collection.patient_enc_coll_id;


--
-- Name: qt_patient_set_collection; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.qt_patient_set_collection (
    patient_set_coll_id bigint NOT NULL,
    result_instance_id integer,
    set_index integer,
    patient_num integer
);


ALTER TABLE i2b2crcdata.qt_patient_set_collection OWNER TO i2b2crcdata;

--
-- Name: qt_patient_set_collection_patient_set_coll_id_seq; Type: SEQUENCE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE SEQUENCE i2b2crcdata.qt_patient_set_collection_patient_set_coll_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2crcdata.qt_patient_set_collection_patient_set_coll_id_seq OWNER TO i2b2crcdata;

--
-- Name: qt_patient_set_collection_patient_set_coll_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER SEQUENCE i2b2crcdata.qt_patient_set_collection_patient_set_coll_id_seq OWNED BY i2b2crcdata.qt_patient_set_collection.patient_set_coll_id;


--
-- Name: qt_pdo_query_master; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.qt_pdo_query_master (
    query_master_id integer NOT NULL,
    user_id character varying(50) NOT NULL,
    group_id character varying(50) NOT NULL,
    create_date timestamp without time zone NOT NULL,
    request_xml text,
    i2b2_request_xml text
);


ALTER TABLE i2b2crcdata.qt_pdo_query_master OWNER TO i2b2crcdata;

--
-- Name: qt_pdo_query_master_query_master_id_seq; Type: SEQUENCE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE SEQUENCE i2b2crcdata.qt_pdo_query_master_query_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2crcdata.qt_pdo_query_master_query_master_id_seq OWNER TO i2b2crcdata;

--
-- Name: qt_pdo_query_master_query_master_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER SEQUENCE i2b2crcdata.qt_pdo_query_master_query_master_id_seq OWNED BY i2b2crcdata.qt_pdo_query_master.query_master_id;


--
-- Name: qt_privilege; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.qt_privilege (
    protection_label_cd character varying(1500) NOT NULL,
    dataprot_cd character varying(1000),
    hivemgmt_cd character varying(1000),
    plugin_id integer
);


ALTER TABLE i2b2crcdata.qt_privilege OWNER TO i2b2crcdata;

--
-- Name: qt_query_instance; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.qt_query_instance (
    query_instance_id integer NOT NULL,
    query_master_id integer,
    user_id character varying(50) NOT NULL,
    group_id character varying(50) NOT NULL,
    batch_mode character varying(50),
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone,
    delete_flag character varying(3),
    status_type_id integer,
    message text
);


ALTER TABLE i2b2crcdata.qt_query_instance OWNER TO i2b2crcdata;

--
-- Name: qt_query_instance_query_instance_id_seq; Type: SEQUENCE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE SEQUENCE i2b2crcdata.qt_query_instance_query_instance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2crcdata.qt_query_instance_query_instance_id_seq OWNER TO i2b2crcdata;

--
-- Name: qt_query_instance_query_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER SEQUENCE i2b2crcdata.qt_query_instance_query_instance_id_seq OWNED BY i2b2crcdata.qt_query_instance.query_instance_id;


--
-- Name: qt_query_master; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.qt_query_master (
    query_master_id integer NOT NULL,
    name character varying(250) NOT NULL,
    user_id character varying(50) NOT NULL,
    group_id character varying(50) NOT NULL,
    master_type_cd character varying(2000),
    plugin_id integer,
    create_date timestamp without time zone NOT NULL,
    delete_date timestamp without time zone,
    delete_flag character varying(3),
    request_xml text,
    generated_sql text,
    i2b2_request_xml text,
    pm_xml text
);


ALTER TABLE i2b2crcdata.qt_query_master OWNER TO i2b2crcdata;

--
-- Name: qt_query_master_query_master_id_seq; Type: SEQUENCE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE SEQUENCE i2b2crcdata.qt_query_master_query_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2crcdata.qt_query_master_query_master_id_seq OWNER TO i2b2crcdata;

--
-- Name: qt_query_master_query_master_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER SEQUENCE i2b2crcdata.qt_query_master_query_master_id_seq OWNED BY i2b2crcdata.qt_query_master.query_master_id;


--
-- Name: qt_query_result_instance; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.qt_query_result_instance (
    result_instance_id integer NOT NULL,
    query_instance_id integer,
    result_type_id integer NOT NULL,
    set_size integer,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone,
    status_type_id integer NOT NULL,
    delete_flag character varying(3),
    message text,
    description character varying(200),
    real_set_size integer,
    obfusc_method character varying(500)
);


ALTER TABLE i2b2crcdata.qt_query_result_instance OWNER TO i2b2crcdata;

--
-- Name: qt_query_result_instance_result_instance_id_seq; Type: SEQUENCE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE SEQUENCE i2b2crcdata.qt_query_result_instance_result_instance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2crcdata.qt_query_result_instance_result_instance_id_seq OWNER TO i2b2crcdata;

--
-- Name: qt_query_result_instance_result_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER SEQUENCE i2b2crcdata.qt_query_result_instance_result_instance_id_seq OWNED BY i2b2crcdata.qt_query_result_instance.result_instance_id;


--
-- Name: qt_query_result_type; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.qt_query_result_type (
    result_type_id integer NOT NULL,
    name character varying(100),
    description character varying(200),
    display_type_id character varying(500),
    visual_attribute_type_id character varying(3),
    user_role_cd character varying(255),
    classname character varying(200)
);


ALTER TABLE i2b2crcdata.qt_query_result_type OWNER TO i2b2crcdata;

--
-- Name: qt_query_status_type; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.qt_query_status_type (
    status_type_id integer NOT NULL,
    name character varying(100),
    description character varying(200)
);


ALTER TABLE i2b2crcdata.qt_query_status_type OWNER TO i2b2crcdata;

--
-- Name: qt_xml_result; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.qt_xml_result (
    xml_result_id integer NOT NULL,
    result_instance_id integer,
    xml_value text
);


ALTER TABLE i2b2crcdata.qt_xml_result OWNER TO i2b2crcdata;

--
-- Name: qt_xml_result_xml_result_id_seq; Type: SEQUENCE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE SEQUENCE i2b2crcdata.qt_xml_result_xml_result_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2crcdata.qt_xml_result_xml_result_id_seq OWNER TO i2b2crcdata;

--
-- Name: qt_xml_result_xml_result_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER SEQUENCE i2b2crcdata.qt_xml_result_xml_result_id_seq OWNED BY i2b2crcdata.qt_xml_result.xml_result_id;


--
-- Name: set_type; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.set_type (
    id integer NOT NULL,
    name character varying(500),
    create_date timestamp without time zone
);


ALTER TABLE i2b2crcdata.set_type OWNER TO i2b2crcdata;

--
-- Name: set_upload_status; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.set_upload_status (
    upload_id integer NOT NULL,
    set_type_id integer NOT NULL,
    source_cd character varying(50) NOT NULL,
    no_of_record bigint,
    loaded_record bigint,
    deleted_record bigint,
    load_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone,
    load_status character varying(100),
    message text,
    input_file_name text,
    log_file_name text,
    transform_name character varying(500)
);


ALTER TABLE i2b2crcdata.set_upload_status OWNER TO i2b2crcdata;

--
-- Name: source_master; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.source_master (
    source_cd character varying(50) NOT NULL,
    description character varying(300),
    create_date timestamp without time zone
);


ALTER TABLE i2b2crcdata.source_master OWNER TO i2b2crcdata;

--
-- Name: upload_status; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.upload_status (
    upload_id integer NOT NULL,
    upload_label character varying(500) NOT NULL,
    user_id character varying(100) NOT NULL,
    source_cd character varying(50) NOT NULL,
    no_of_record bigint,
    loaded_record bigint,
    deleted_record bigint,
    load_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone,
    load_status character varying(100),
    message text,
    input_file_name text,
    log_file_name text,
    transform_name character varying(500)
);


ALTER TABLE i2b2crcdata.upload_status OWNER TO i2b2crcdata;

--
-- Name: upload_status_upload_id_seq; Type: SEQUENCE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE SEQUENCE i2b2crcdata.upload_status_upload_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2crcdata.upload_status_upload_id_seq OWNER TO i2b2crcdata;

--
-- Name: upload_status_upload_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER SEQUENCE i2b2crcdata.upload_status_upload_id_seq OWNED BY i2b2crcdata.upload_status.upload_id;


--
-- Name: visit_dimension; Type: TABLE; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE TABLE i2b2crcdata.visit_dimension (
    encounter_num integer NOT NULL,
    patient_num integer NOT NULL,
    active_status_cd character varying(50),
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    inout_cd character varying(50),
    location_cd character varying(50),
    location_path character varying(900),
    length_of_stay integer,
    visit_blob text,
    update_date timestamp without time zone,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    upload_id integer
);


ALTER TABLE i2b2crcdata.visit_dimension OWNER TO i2b2crcdata;

--
-- Name: crc_analysis_job; Type: TABLE; Schema: i2b2hive; Owner: i2b2hive
--

CREATE TABLE i2b2hive.crc_analysis_job (
    job_id character varying(10) NOT NULL,
    queue_name character varying(50),
    status_type_id integer,
    domain_id character varying(255),
    project_id character varying(500),
    user_id character varying(255),
    request_xml text,
    create_date timestamp without time zone,
    update_date timestamp without time zone
);


ALTER TABLE i2b2hive.crc_analysis_job OWNER TO i2b2hive;

--
-- Name: crc_db_lookup; Type: TABLE; Schema: i2b2hive; Owner: i2b2hive
--

CREATE TABLE i2b2hive.crc_db_lookup (
    c_domain_id character varying(255) NOT NULL,
    c_project_path character varying(255) NOT NULL,
    c_owner_id character varying(255) NOT NULL,
    c_db_fullschema character varying(255) NOT NULL,
    c_db_datasource character varying(255) NOT NULL,
    c_db_servertype character varying(255) NOT NULL,
    c_db_nicename character varying(255),
    c_db_tooltip character varying(255),
    c_comment text,
    c_entry_date timestamp without time zone,
    c_change_date timestamp without time zone,
    c_status_cd character(1)
);


ALTER TABLE i2b2hive.crc_db_lookup OWNER TO i2b2hive;

--
-- Name: hive_cell_params; Type: TABLE; Schema: i2b2hive; Owner: i2b2hive
--

CREATE TABLE i2b2hive.hive_cell_params (
    id integer NOT NULL,
    datatype_cd character varying(50),
    cell_id character varying(50) NOT NULL,
    param_name_cd character varying(200) NOT NULL,
    value text,
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2hive.hive_cell_params OWNER TO i2b2hive;

--
-- Name: im_db_lookup; Type: TABLE; Schema: i2b2hive; Owner: i2b2hive
--

CREATE TABLE i2b2hive.im_db_lookup (
    c_domain_id character varying(255) NOT NULL,
    c_project_path character varying(255) NOT NULL,
    c_owner_id character varying(255) NOT NULL,
    c_db_fullschema character varying(255) NOT NULL,
    c_db_datasource character varying(255) NOT NULL,
    c_db_servertype character varying(255) NOT NULL,
    c_db_nicename character varying(255),
    c_db_tooltip character varying(255),
    c_comment text,
    c_entry_date timestamp without time zone,
    c_change_date timestamp without time zone,
    c_status_cd character(1)
);


ALTER TABLE i2b2hive.im_db_lookup OWNER TO i2b2hive;

--
-- Name: ont_db_lookup; Type: TABLE; Schema: i2b2hive; Owner: i2b2hive
--

CREATE TABLE i2b2hive.ont_db_lookup (
    c_domain_id character varying(255) NOT NULL,
    c_project_path character varying(255) NOT NULL,
    c_owner_id character varying(255) NOT NULL,
    c_db_fullschema character varying(255) NOT NULL,
    c_db_datasource character varying(255) NOT NULL,
    c_db_servertype character varying(255) NOT NULL,
    c_db_nicename character varying(255),
    c_db_tooltip character varying(255),
    c_comment text,
    c_entry_date timestamp without time zone,
    c_change_date timestamp without time zone,
    c_status_cd character(1)
);


ALTER TABLE i2b2hive.ont_db_lookup OWNER TO i2b2hive;

--
-- Name: work_db_lookup; Type: TABLE; Schema: i2b2hive; Owner: i2b2hive
--

CREATE TABLE i2b2hive.work_db_lookup (
    c_domain_id character varying(255) NOT NULL,
    c_project_path character varying(255) NOT NULL,
    c_owner_id character varying(255) NOT NULL,
    c_db_fullschema character varying(255) NOT NULL,
    c_db_datasource character varying(255) NOT NULL,
    c_db_servertype character varying(255) NOT NULL,
    c_db_nicename character varying(255),
    c_db_tooltip character varying(255),
    c_comment text,
    c_entry_date timestamp without time zone,
    c_change_date timestamp without time zone,
    c_status_cd character(1)
);


ALTER TABLE i2b2hive.work_db_lookup OWNER TO i2b2hive;

--
-- Name: im_audit; Type: TABLE; Schema: i2b2imdata; Owner: i2b2imdata
--

CREATE TABLE i2b2imdata.im_audit (
    query_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    lcl_site character varying(50) NOT NULL,
    lcl_id character varying(200) NOT NULL,
    user_id character varying(50) NOT NULL,
    project_id character varying(50) NOT NULL,
    comments text
);


ALTER TABLE i2b2imdata.im_audit OWNER TO i2b2imdata;

--
-- Name: im_mpi_demographics; Type: TABLE; Schema: i2b2imdata; Owner: i2b2imdata
--

CREATE TABLE i2b2imdata.im_mpi_demographics (
    global_id character varying(200) NOT NULL,
    global_status character varying(50),
    demographics character varying(400),
    update_date timestamp without time zone,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    upload_id integer
);


ALTER TABLE i2b2imdata.im_mpi_demographics OWNER TO i2b2imdata;

--
-- Name: im_mpi_mapping; Type: TABLE; Schema: i2b2imdata; Owner: i2b2imdata
--

CREATE TABLE i2b2imdata.im_mpi_mapping (
    global_id character varying(200) NOT NULL,
    lcl_site character varying(50) NOT NULL,
    lcl_id character varying(200) NOT NULL,
    lcl_status character varying(50),
    update_date timestamp without time zone NOT NULL,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    upload_id integer
);


ALTER TABLE i2b2imdata.im_mpi_mapping OWNER TO i2b2imdata;

--
-- Name: im_project_patients; Type: TABLE; Schema: i2b2imdata; Owner: i2b2imdata
--

CREATE TABLE i2b2imdata.im_project_patients (
    project_id character varying(50) NOT NULL,
    global_id character varying(200) NOT NULL,
    patient_project_status character varying(50),
    update_date timestamp without time zone,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    upload_id integer
);


ALTER TABLE i2b2imdata.im_project_patients OWNER TO i2b2imdata;

--
-- Name: im_project_sites; Type: TABLE; Schema: i2b2imdata; Owner: i2b2imdata
--

CREATE TABLE i2b2imdata.im_project_sites (
    project_id character varying(50) NOT NULL,
    lcl_site character varying(50) NOT NULL,
    project_status character varying(50),
    update_date timestamp without time zone,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    upload_id integer
);


ALTER TABLE i2b2imdata.im_project_sites OWNER TO i2b2imdata;

--
-- Name: birn; Type: TABLE; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE TABLE i2b2metadata.birn (
    c_hlevel integer NOT NULL,
    c_fullname character varying(700) NOT NULL,
    c_name character varying(2000) NOT NULL,
    c_synonym_cd character(1) NOT NULL,
    c_visualattributes character(3) NOT NULL,
    c_totalnum integer,
    c_basecode character varying(50),
    c_metadataxml text,
    c_facttablecolumn character varying(50) NOT NULL,
    c_tablename character varying(50) NOT NULL,
    c_columnname character varying(50) NOT NULL,
    c_columndatatype character varying(50) NOT NULL,
    c_operator character varying(10) NOT NULL,
    c_dimcode character varying(700) NOT NULL,
    c_comment text,
    c_tooltip character varying(900),
    m_applied_path character varying(700) NOT NULL,
    update_date timestamp without time zone NOT NULL,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    valuetype_cd character varying(50),
    m_exclusion_cd character varying(25),
    c_path character varying(700),
    c_symbol character varying(50)
);


ALTER TABLE i2b2metadata.birn OWNER TO i2b2metadata;

--
-- Name: custom_meta; Type: TABLE; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE TABLE i2b2metadata.custom_meta (
    c_hlevel integer NOT NULL,
    c_fullname character varying(700) NOT NULL,
    c_name character varying(2000) NOT NULL,
    c_synonym_cd character(1) NOT NULL,
    c_visualattributes character(3) NOT NULL,
    c_totalnum integer,
    c_basecode character varying(50),
    c_metadataxml text,
    c_facttablecolumn character varying(50) NOT NULL,
    c_tablename character varying(50) NOT NULL,
    c_columnname character varying(50) NOT NULL,
    c_columndatatype character varying(50) NOT NULL,
    c_operator character varying(10) NOT NULL,
    c_dimcode character varying(700) NOT NULL,
    c_comment text,
    c_tooltip character varying(900),
    m_applied_path character varying(700) NOT NULL,
    update_date timestamp without time zone NOT NULL,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    valuetype_cd character varying(50),
    m_exclusion_cd character varying(25),
    c_path character varying(700),
    c_symbol character varying(50)
);


ALTER TABLE i2b2metadata.custom_meta OWNER TO i2b2metadata;

--
-- Name: i2b2; Type: TABLE; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE TABLE i2b2metadata.i2b2 (
    c_hlevel integer NOT NULL,
    c_fullname character varying(700) NOT NULL,
    c_name character varying(2000) NOT NULL,
    c_synonym_cd character(1) NOT NULL,
    c_visualattributes character(3) NOT NULL,
    c_totalnum integer,
    c_basecode character varying(50),
    c_metadataxml text,
    c_facttablecolumn character varying(50) NOT NULL,
    c_tablename character varying(50) NOT NULL,
    c_columnname character varying(50) NOT NULL,
    c_columndatatype character varying(50) NOT NULL,
    c_operator character varying(10) NOT NULL,
    c_dimcode character varying(700) NOT NULL,
    c_comment text,
    c_tooltip character varying(900),
    m_applied_path character varying(700) NOT NULL,
    update_date timestamp without time zone NOT NULL,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    valuetype_cd character varying(50),
    m_exclusion_cd character varying(25),
    c_path character varying(700),
    c_symbol character varying(50)
);


ALTER TABLE i2b2metadata.i2b2 OWNER TO i2b2metadata;

--
-- Name: icd10_icd9; Type: TABLE; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE TABLE i2b2metadata.icd10_icd9 (
    c_hlevel integer NOT NULL,
    c_fullname character varying(700) NOT NULL,
    c_name character varying(2000) NOT NULL,
    c_synonym_cd character(1) NOT NULL,
    c_visualattributes character(3) NOT NULL,
    c_totalnum integer,
    c_basecode character varying(50),
    c_metadataxml text,
    c_facttablecolumn character varying(50) NOT NULL,
    c_tablename character varying(50) NOT NULL,
    c_columnname character varying(50) NOT NULL,
    c_columndatatype character varying(50) NOT NULL,
    c_operator character varying(10) NOT NULL,
    c_dimcode character varying(700) NOT NULL,
    c_comment text,
    c_tooltip character varying(900),
    m_applied_path character varying(700) NOT NULL,
    update_date timestamp without time zone NOT NULL,
    download_date timestamp without time zone,
    import_date timestamp without time zone,
    sourcesystem_cd character varying(50),
    valuetype_cd character varying(50),
    m_exclusion_cd character varying(25),
    c_path character varying(700),
    c_symbol character varying(50),
    plain_code character varying(25)
);


ALTER TABLE i2b2metadata.icd10_icd9 OWNER TO i2b2metadata;

--
-- Name: ont_process_status; Type: TABLE; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE TABLE i2b2metadata.ont_process_status (
    process_id integer NOT NULL,
    process_type_cd character varying(50),
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    process_step_cd character varying(50),
    process_status_cd character varying(50),
    crc_upload_id integer,
    status_cd character varying(50),
    message text,
    entry_date timestamp without time zone,
    change_date timestamp without time zone,
    changedby_char character(50)
);


ALTER TABLE i2b2metadata.ont_process_status OWNER TO i2b2metadata;

--
-- Name: ont_process_status_process_id_seq; Type: SEQUENCE; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE SEQUENCE i2b2metadata.ont_process_status_process_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2metadata.ont_process_status_process_id_seq OWNER TO i2b2metadata;

--
-- Name: ont_process_status_process_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2metadata; Owner: i2b2metadata
--

ALTER SEQUENCE i2b2metadata.ont_process_status_process_id_seq OWNED BY i2b2metadata.ont_process_status.process_id;


--
-- Name: schemes; Type: TABLE; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE TABLE i2b2metadata.schemes (
    c_key character varying(50) NOT NULL,
    c_name character varying(50) NOT NULL,
    c_description character varying(100)
);


ALTER TABLE i2b2metadata.schemes OWNER TO i2b2metadata;

--
-- Name: table_access; Type: TABLE; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE TABLE i2b2metadata.table_access (
    c_table_cd character varying(50) NOT NULL,
    c_table_name character varying(50) NOT NULL,
    c_protected_access character(1),
    c_ontology_protection text,
    c_hlevel integer NOT NULL,
    c_fullname character varying(700) NOT NULL,
    c_name character varying(2000) NOT NULL,
    c_synonym_cd character(1) NOT NULL,
    c_visualattributes character(3) NOT NULL,
    c_totalnum integer,
    c_basecode character varying(50),
    c_metadataxml text,
    c_facttablecolumn character varying(50) NOT NULL,
    c_dimtablename character varying(50) NOT NULL,
    c_columnname character varying(50) NOT NULL,
    c_columndatatype character varying(50) NOT NULL,
    c_operator character varying(10) NOT NULL,
    c_dimcode character varying(700) NOT NULL,
    c_comment text,
    c_tooltip character varying(900),
    c_entry_date timestamp without time zone,
    c_change_date timestamp without time zone,
    c_status_cd character(1),
    valuetype_cd character varying(50)
);


ALTER TABLE i2b2metadata.table_access OWNER TO i2b2metadata;

--
-- Name: pm_approvals; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_approvals (
    approval_id character varying(50) NOT NULL,
    approval_name character varying(255),
    approval_description character varying(2000),
    approval_activation_date timestamp without time zone,
    approval_expiration_date timestamp without time zone,
    object_cd character varying(50),
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_approvals OWNER TO i2b2pm;

--
-- Name: pm_approvals_params; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_approvals_params (
    id integer NOT NULL,
    approval_id character varying(50) NOT NULL,
    param_name_cd character varying(50) NOT NULL,
    value text,
    activation_date timestamp without time zone,
    expiration_date timestamp without time zone,
    datatype_cd character varying(50),
    object_cd character varying(50),
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_approvals_params OWNER TO i2b2pm;

--
-- Name: pm_approvals_params_id_seq; Type: SEQUENCE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE SEQUENCE i2b2pm.pm_approvals_params_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2pm.pm_approvals_params_id_seq OWNER TO i2b2pm;

--
-- Name: pm_approvals_params_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2pm; Owner: i2b2pm
--

ALTER SEQUENCE i2b2pm.pm_approvals_params_id_seq OWNED BY i2b2pm.pm_approvals_params.id;


--
-- Name: pm_cell_data; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_cell_data (
    cell_id character varying(50) NOT NULL,
    project_path character varying(255) NOT NULL,
    name character varying(255),
    method_cd character varying(255),
    url character varying(255),
    can_override integer,
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_cell_data OWNER TO i2b2pm;

--
-- Name: pm_cell_params; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_cell_params (
    id integer NOT NULL,
    datatype_cd character varying(50),
    cell_id character varying(50) NOT NULL,
    project_path character varying(255) NOT NULL,
    param_name_cd character varying(50) NOT NULL,
    value text,
    can_override integer,
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_cell_params OWNER TO i2b2pm;

--
-- Name: pm_cell_params_id_seq; Type: SEQUENCE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE SEQUENCE i2b2pm.pm_cell_params_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2pm.pm_cell_params_id_seq OWNER TO i2b2pm;

--
-- Name: pm_cell_params_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2pm; Owner: i2b2pm
--

ALTER SEQUENCE i2b2pm.pm_cell_params_id_seq OWNED BY i2b2pm.pm_cell_params.id;


--
-- Name: pm_global_params; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_global_params (
    id integer NOT NULL,
    datatype_cd character varying(50),
    param_name_cd character varying(50) NOT NULL,
    project_path character varying(255) NOT NULL,
    value text,
    can_override integer,
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_global_params OWNER TO i2b2pm;

--
-- Name: pm_global_params_id_seq; Type: SEQUENCE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE SEQUENCE i2b2pm.pm_global_params_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2pm.pm_global_params_id_seq OWNER TO i2b2pm;

--
-- Name: pm_global_params_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2pm; Owner: i2b2pm
--

ALTER SEQUENCE i2b2pm.pm_global_params_id_seq OWNED BY i2b2pm.pm_global_params.id;


--
-- Name: pm_hive_data; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_hive_data (
    domain_id character varying(50) NOT NULL,
    helpurl character varying(255),
    domain_name character varying(255),
    environment_cd character varying(255),
    active integer,
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_hive_data OWNER TO i2b2pm;

--
-- Name: pm_hive_params; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_hive_params (
    id integer NOT NULL,
    datatype_cd character varying(50),
    domain_id character varying(50) NOT NULL,
    param_name_cd character varying(50) NOT NULL,
    value text,
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_hive_params OWNER TO i2b2pm;

--
-- Name: pm_hive_params_id_seq; Type: SEQUENCE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE SEQUENCE i2b2pm.pm_hive_params_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2pm.pm_hive_params_id_seq OWNER TO i2b2pm;

--
-- Name: pm_hive_params_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2pm; Owner: i2b2pm
--

ALTER SEQUENCE i2b2pm.pm_hive_params_id_seq OWNED BY i2b2pm.pm_hive_params.id;


--
-- Name: pm_project_data; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_project_data (
    project_id character varying(50) NOT NULL,
    project_name character varying(255),
    project_wiki character varying(255),
    project_key character varying(255),
    project_path character varying(255),
    project_description character varying(2000),
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_project_data OWNER TO i2b2pm;

--
-- Name: pm_project_params; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_project_params (
    id integer NOT NULL,
    datatype_cd character varying(50),
    project_id character varying(50) NOT NULL,
    param_name_cd character varying(50) NOT NULL,
    value text,
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_project_params OWNER TO i2b2pm;

--
-- Name: pm_project_params_id_seq; Type: SEQUENCE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE SEQUENCE i2b2pm.pm_project_params_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2pm.pm_project_params_id_seq OWNER TO i2b2pm;

--
-- Name: pm_project_params_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2pm; Owner: i2b2pm
--

ALTER SEQUENCE i2b2pm.pm_project_params_id_seq OWNED BY i2b2pm.pm_project_params.id;


--
-- Name: pm_project_request; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_project_request (
    id integer NOT NULL,
    title character varying(255),
    request_xml text NOT NULL,
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50),
    project_id character varying(50),
    submit_char character varying(50)
);


ALTER TABLE i2b2pm.pm_project_request OWNER TO i2b2pm;

--
-- Name: pm_project_request_id_seq; Type: SEQUENCE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE SEQUENCE i2b2pm.pm_project_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2pm.pm_project_request_id_seq OWNER TO i2b2pm;

--
-- Name: pm_project_request_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2pm; Owner: i2b2pm
--

ALTER SEQUENCE i2b2pm.pm_project_request_id_seq OWNED BY i2b2pm.pm_project_request.id;


--
-- Name: pm_project_user_params; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_project_user_params (
    id integer NOT NULL,
    datatype_cd character varying(50),
    project_id character varying(50) NOT NULL,
    user_id character varying(50) NOT NULL,
    param_name_cd character varying(50) NOT NULL,
    value text,
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_project_user_params OWNER TO i2b2pm;

--
-- Name: pm_project_user_params_id_seq; Type: SEQUENCE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE SEQUENCE i2b2pm.pm_project_user_params_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2pm.pm_project_user_params_id_seq OWNER TO i2b2pm;

--
-- Name: pm_project_user_params_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2pm; Owner: i2b2pm
--

ALTER SEQUENCE i2b2pm.pm_project_user_params_id_seq OWNED BY i2b2pm.pm_project_user_params.id;


--
-- Name: pm_project_user_roles; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_project_user_roles (
    project_id character varying(50) NOT NULL,
    user_id character varying(50) NOT NULL,
    user_role_cd character varying(255) NOT NULL,
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_project_user_roles OWNER TO i2b2pm;

--
-- Name: pm_role_requirement; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_role_requirement (
    table_cd character varying(50) NOT NULL,
    column_cd character varying(50) NOT NULL,
    read_hivemgmt_cd character varying(50) NOT NULL,
    write_hivemgmt_cd character varying(50) NOT NULL,
    name_char character varying(2000),
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_role_requirement OWNER TO i2b2pm;

--
-- Name: pm_user_data; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_user_data (
    user_id character varying(50) NOT NULL,
    full_name character varying(255),
    password character varying(255),
    email character varying(255),
    project_path character varying(255),
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_user_data OWNER TO i2b2pm;

--
-- Name: pm_user_login; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_user_login (
    user_id character varying(50) NOT NULL,
    attempt_cd character varying(50) NOT NULL,
    entry_date timestamp without time zone NOT NULL,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_user_login OWNER TO i2b2pm;

--
-- Name: pm_user_params; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_user_params (
    id integer NOT NULL,
    datatype_cd character varying(50),
    user_id character varying(50) NOT NULL,
    param_name_cd character varying(50) NOT NULL,
    value text,
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_user_params OWNER TO i2b2pm;

--
-- Name: pm_user_params_id_seq; Type: SEQUENCE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE SEQUENCE i2b2pm.pm_user_params_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE i2b2pm.pm_user_params_id_seq OWNER TO i2b2pm;

--
-- Name: pm_user_params_id_seq; Type: SEQUENCE OWNED BY; Schema: i2b2pm; Owner: i2b2pm
--

ALTER SEQUENCE i2b2pm.pm_user_params_id_seq OWNED BY i2b2pm.pm_user_params.id;


--
-- Name: pm_user_session; Type: TABLE; Schema: i2b2pm; Owner: i2b2pm
--

CREATE TABLE i2b2pm.pm_user_session (
    user_id character varying(50) NOT NULL,
    session_id character varying(50) NOT NULL,
    expired_date timestamp without time zone,
    change_date timestamp without time zone,
    entry_date timestamp without time zone,
    changeby_char character varying(50),
    status_cd character varying(50)
);


ALTER TABLE i2b2pm.pm_user_session OWNER TO i2b2pm;

--
-- Name: workplace; Type: TABLE; Schema: i2b2workdata; Owner: i2b2workdata
--

CREATE TABLE i2b2workdata.workplace (
    c_name character varying(255) NOT NULL,
    c_user_id character varying(255) NOT NULL,
    c_group_id character varying(255) NOT NULL,
    c_share_id character varying(255),
    c_index character varying(255) NOT NULL,
    c_parent_index character varying(255),
    c_visualattributes character(3) NOT NULL,
    c_protected_access character(1),
    c_tooltip character varying(255),
    c_work_xml text,
    c_work_xml_schema text,
    c_work_xml_i2b2_type character varying(255),
    c_entry_date timestamp without time zone,
    c_change_date timestamp without time zone,
    c_status_cd character(1)
);


ALTER TABLE i2b2workdata.workplace OWNER TO i2b2workdata;

--
-- Name: workplace_access; Type: TABLE; Schema: i2b2workdata; Owner: i2b2workdata
--

CREATE TABLE i2b2workdata.workplace_access (
    c_table_cd character varying(255) NOT NULL,
    c_table_name character varying(255) NOT NULL,
    c_protected_access character(1),
    c_hlevel integer NOT NULL,
    c_name character varying(255) NOT NULL,
    c_user_id character varying(255) NOT NULL,
    c_group_id character varying(255) NOT NULL,
    c_share_id character varying(255),
    c_index character varying(255) NOT NULL,
    c_parent_index character varying(255),
    c_visualattributes character(3) NOT NULL,
    c_tooltip character varying(255),
    c_entry_date timestamp without time zone,
    c_change_date timestamp without time zone,
    c_status_cd character(1)
);


ALTER TABLE i2b2workdata.workplace_access OWNER TO i2b2workdata;

--
-- Name: observation_fact text_search_index; Type: DEFAULT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.observation_fact ALTER COLUMN text_search_index SET DEFAULT nextval('i2b2crcdata.observation_fact_text_search_index_seq'::regclass);


--
-- Name: qt_patient_enc_collection patient_enc_coll_id; Type: DEFAULT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_patient_enc_collection ALTER COLUMN patient_enc_coll_id SET DEFAULT nextval('i2b2crcdata.qt_patient_enc_collection_patient_enc_coll_id_seq'::regclass);


--
-- Name: qt_patient_set_collection patient_set_coll_id; Type: DEFAULT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_patient_set_collection ALTER COLUMN patient_set_coll_id SET DEFAULT nextval('i2b2crcdata.qt_patient_set_collection_patient_set_coll_id_seq'::regclass);


--
-- Name: qt_pdo_query_master query_master_id; Type: DEFAULT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_pdo_query_master ALTER COLUMN query_master_id SET DEFAULT nextval('i2b2crcdata.qt_pdo_query_master_query_master_id_seq'::regclass);


--
-- Name: qt_query_instance query_instance_id; Type: DEFAULT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_query_instance ALTER COLUMN query_instance_id SET DEFAULT nextval('i2b2crcdata.qt_query_instance_query_instance_id_seq'::regclass);


--
-- Name: qt_query_master query_master_id; Type: DEFAULT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_query_master ALTER COLUMN query_master_id SET DEFAULT nextval('i2b2crcdata.qt_query_master_query_master_id_seq'::regclass);


--
-- Name: qt_query_result_instance result_instance_id; Type: DEFAULT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_query_result_instance ALTER COLUMN result_instance_id SET DEFAULT nextval('i2b2crcdata.qt_query_result_instance_result_instance_id_seq'::regclass);


--
-- Name: qt_xml_result xml_result_id; Type: DEFAULT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_xml_result ALTER COLUMN xml_result_id SET DEFAULT nextval('i2b2crcdata.qt_xml_result_xml_result_id_seq'::regclass);


--
-- Name: upload_status upload_id; Type: DEFAULT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.upload_status ALTER COLUMN upload_id SET DEFAULT nextval('i2b2crcdata.upload_status_upload_id_seq'::regclass);


--
-- Name: ont_process_status process_id; Type: DEFAULT; Schema: i2b2metadata; Owner: i2b2metadata
--

ALTER TABLE ONLY i2b2metadata.ont_process_status ALTER COLUMN process_id SET DEFAULT nextval('i2b2metadata.ont_process_status_process_id_seq'::regclass);


--
-- Name: pm_approvals_params id; Type: DEFAULT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_approvals_params ALTER COLUMN id SET DEFAULT nextval('i2b2pm.pm_approvals_params_id_seq'::regclass);


--
-- Name: pm_cell_params id; Type: DEFAULT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_cell_params ALTER COLUMN id SET DEFAULT nextval('i2b2pm.pm_cell_params_id_seq'::regclass);


--
-- Name: pm_global_params id; Type: DEFAULT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_global_params ALTER COLUMN id SET DEFAULT nextval('i2b2pm.pm_global_params_id_seq'::regclass);


--
-- Name: pm_hive_params id; Type: DEFAULT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_hive_params ALTER COLUMN id SET DEFAULT nextval('i2b2pm.pm_hive_params_id_seq'::regclass);


--
-- Name: pm_project_params id; Type: DEFAULT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_project_params ALTER COLUMN id SET DEFAULT nextval('i2b2pm.pm_project_params_id_seq'::regclass);


--
-- Name: pm_project_request id; Type: DEFAULT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_project_request ALTER COLUMN id SET DEFAULT nextval('i2b2pm.pm_project_request_id_seq'::regclass);


--
-- Name: pm_project_user_params id; Type: DEFAULT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_project_user_params ALTER COLUMN id SET DEFAULT nextval('i2b2pm.pm_project_user_params_id_seq'::regclass);


--
-- Name: pm_user_params id; Type: DEFAULT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_user_params ALTER COLUMN id SET DEFAULT nextval('i2b2pm.pm_user_params_id_seq'::regclass);


--
-- Data for Name: archive_observation_fact; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.archive_observation_fact (encounter_num, patient_num, concept_cd, provider_id, start_date, modifier_cd, instance_num, valtype_cd, tval_char, nval_num, valueflag_cd, quantity_num, units_cd, end_date, location_cd, observation_blob, confidence_num, update_date, download_date, import_date, sourcesystem_cd, upload_id, text_search_index, archive_upload_id) FROM stdin;
\.


--
-- Data for Name: code_lookup; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.code_lookup (table_cd, column_cd, code_cd, name_char, lookup_blob, upload_date, update_date, download_date, import_date, sourcesystem_cd, upload_id) FROM stdin;
\.


--
-- Data for Name: concept_dimension; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.concept_dimension (concept_path, concept_cd, name_char, concept_blob, update_date, download_date, import_date, sourcesystem_cd, upload_id) FROM stdin;
\.


--
-- Data for Name: datamart_report; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.datamart_report (total_patient, total_observationfact, total_event, report_date) FROM stdin;
\.


--
-- Data for Name: encounter_mapping; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.encounter_mapping (encounter_ide, encounter_ide_source, project_id, encounter_num, patient_ide, patient_ide_source, encounter_ide_status, upload_date, update_date, download_date, import_date, sourcesystem_cd, upload_id) FROM stdin;
\.


--
-- Data for Name: modifier_dimension; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.modifier_dimension (modifier_path, modifier_cd, name_char, modifier_blob, update_date, download_date, import_date, sourcesystem_cd, upload_id) FROM stdin;
\.


--
-- Data for Name: observation_fact; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.observation_fact (encounter_num, patient_num, concept_cd, provider_id, start_date, modifier_cd, instance_num, valtype_cd, tval_char, nval_num, valueflag_cd, quantity_num, units_cd, end_date, location_cd, observation_blob, confidence_num, update_date, download_date, import_date, sourcesystem_cd, upload_id, text_search_index) FROM stdin;
\.


--
-- Data for Name: patient_dimension; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.patient_dimension (patient_num, vital_status_cd, birth_date, death_date, sex_cd, age_in_years_num, language_cd, race_cd, marital_status_cd, religion_cd, zip_cd, statecityzip_path, income_cd, patient_blob, update_date, download_date, import_date, sourcesystem_cd, upload_id) FROM stdin;
\.


--
-- Data for Name: patient_mapping; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.patient_mapping (patient_ide, patient_ide_source, patient_num, patient_ide_status, project_id, upload_date, update_date, download_date, import_date, sourcesystem_cd, upload_id) FROM stdin;
\.


--
-- Data for Name: provider_dimension; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.provider_dimension (provider_id, provider_path, name_char, provider_blob, update_date, download_date, import_date, sourcesystem_cd, upload_id) FROM stdin;
\.


--
-- Data for Name: qt_analysis_plugin; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.qt_analysis_plugin (plugin_id, plugin_name, description, version_cd, parameter_info, parameter_info_xsd, command_line, working_folder, commandoption_cd, plugin_icon, status_cd, user_id, group_id, create_date, update_date) FROM stdin;
\.


--
-- Data for Name: qt_analysis_plugin_result_type; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.qt_analysis_plugin_result_type (plugin_id, result_type_id) FROM stdin;
\.


--
-- Data for Name: qt_breakdown_path; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.qt_breakdown_path (name, value, create_date, update_date, user_id) FROM stdin;
\.


--
-- Data for Name: qt_patient_enc_collection; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.qt_patient_enc_collection (patient_enc_coll_id, result_instance_id, set_index, patient_num, encounter_num) FROM stdin;
\.


--
-- Data for Name: qt_patient_set_collection; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.qt_patient_set_collection (patient_set_coll_id, result_instance_id, set_index, patient_num) FROM stdin;
\.


--
-- Data for Name: qt_pdo_query_master; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.qt_pdo_query_master (query_master_id, user_id, group_id, create_date, request_xml, i2b2_request_xml) FROM stdin;
\.


--
-- Data for Name: qt_privilege; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.qt_privilege (protection_label_cd, dataprot_cd, hivemgmt_cd, plugin_id) FROM stdin;
PDO_WITHOUT_BLOB	DATA_LDS	USER	\N
PDO_WITH_BLOB	DATA_DEID	USER	\N
SETFINDER_QRY_WITH_DATAOBFSC	DATA_OBFSC	USER	\N
SETFINDER_QRY_WITHOUT_DATAOBFSC	DATA_AGG	USER	\N
UPLOAD	DATA_OBFSC	MANAGER	\N
SETFINDER_QRY_WITH_LGTEXT	DATA_DEID	USER	\N
SETFINDER_QRY_PROTECTED	DATA_PROT	USER	\N
\.


--
-- Data for Name: qt_query_instance; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.qt_query_instance (query_instance_id, query_master_id, user_id, group_id, batch_mode, start_date, end_date, delete_flag, status_type_id, message) FROM stdin;
\.


--
-- Data for Name: qt_query_master; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.qt_query_master (query_master_id, name, user_id, group_id, master_type_cd, plugin_id, create_date, delete_date, delete_flag, request_xml, generated_sql, i2b2_request_xml, pm_xml) FROM stdin;
\.


--
-- Data for Name: qt_query_result_instance; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.qt_query_result_instance (result_instance_id, query_instance_id, result_type_id, set_size, start_date, end_date, status_type_id, delete_flag, message, description, real_set_size, obfusc_method) FROM stdin;
\.


--
-- Data for Name: qt_query_result_type; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.qt_query_result_type (result_type_id, name, description, display_type_id, visual_attribute_type_id, user_role_cd, classname) FROM stdin;
1	PATIENTSET	Patient set	LIST	LA	\N	edu.harvard.i2b2.crc.dao.setfinder.QueryResultPatientSetGenerator
2	PATIENT_ENCOUNTER_SET	Encounter set	LIST	LA	\N	edu.harvard.i2b2.crc.dao.setfinder.QueryResultEncounterSetGenerator
3	XML	Generic query result	CATNUM	LH	\N	\N
4	PATIENT_COUNT_XML	Number of patients	CATNUM	LA	\N	edu.harvard.i2b2.crc.dao.setfinder.QueryResultPatientCountGenerator
5	PATIENT_GENDER_COUNT_XML	Gender patient breakdown	CATNUM	LA	\N	edu.harvard.i2b2.crc.dao.setfinder.QueryResultGenerator
6	PATIENT_VITALSTATUS_COUNT_XML	Vital Status patient breakdown	CATNUM	LA	\N	edu.harvard.i2b2.crc.dao.setfinder.QueryResultGenerator
7	PATIENT_RACE_COUNT_XML	Race patient breakdown	CATNUM	LA	\N	edu.harvard.i2b2.crc.dao.setfinder.QueryResultGenerator
8	PATIENT_AGE_COUNT_XML	Age patient breakdown	CATNUM	LA	\N	edu.harvard.i2b2.crc.dao.setfinder.QueryResultGenerator
9	PATIENTSET	Timeline	LIST	LA	\N	edu.harvard.i2b2.crc.dao.setfinder.QueryResultPatientSetGenerator
10	PATIENT_LOS_XML	Length of stay breakdown	CATNUM	LA	DATA_LDS	edu.harvard.i2b2.crc.dao.setfinder.QueryResultPatientSQLCountGenerator
11	PATIENT_TOP20MEDS_XML	Top 20 medications breakdown	CATNUM	LA	DATA_LDS	edu.harvard.i2b2.crc.dao.setfinder.QueryResultPatientSQLCountGenerator
12	PATIENT_TOP20DIAG_XML	Top 20 diagnoses breakdown	CATNUM	LA	DATA_LDS	edu.harvard.i2b2.crc.dao.setfinder.QueryResultPatientSQLCountGenerator
13	PATIENT_INOUT_XML	Inpatient and outpatient breakdown	CATNUM	LA	DATA_LDS	edu.harvard.i2b2.crc.dao.setfinder.QueryResultPatientSQLCountGenerator
\.


--
-- Data for Name: qt_query_status_type; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.qt_query_status_type (status_type_id, name, description) FROM stdin;
1	QUEUED	 WAITING IN QUEUE TO START PROCESS
2	PROCESSING	PROCESSING
3	FINISHED	FINISHED
4	ERROR	ERROR
5	INCOMPLETE	INCOMPLETE
6	COMPLETED	COMPLETED
7	MEDIUM_QUEUE	MEDIUM QUEUE
8	LARGE_QUEUE	LARGE QUEUE
9	CANCELLED	CANCELLED
10	TIMEDOUT	TIMEDOUT
\.


--
-- Data for Name: qt_xml_result; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.qt_xml_result (xml_result_id, result_instance_id, xml_value) FROM stdin;
\.


--
-- Data for Name: set_type; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.set_type (id, name, create_date) FROM stdin;
1	event_set	2020-09-28 11:13:10.338861
2	patient_set	2020-09-28 11:13:10.348358
3	concept_set	2020-09-28 11:13:10.352921
4	observer_set	2020-09-28 11:13:10.357692
5	observation_set	2020-09-28 11:13:10.362592
6	pid_set	2020-09-28 11:13:10.367347
7	eid_set	2020-09-28 11:13:10.372051
8	modifier_set	2020-09-28 11:13:10.37746
\.


--
-- Data for Name: set_upload_status; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.set_upload_status (upload_id, set_type_id, source_cd, no_of_record, loaded_record, deleted_record, load_date, end_date, load_status, message, input_file_name, log_file_name, transform_name) FROM stdin;
\.


--
-- Data for Name: source_master; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.source_master (source_cd, description, create_date) FROM stdin;
\.


--
-- Data for Name: upload_status; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.upload_status (upload_id, upload_label, user_id, source_cd, no_of_record, loaded_record, deleted_record, load_date, end_date, load_status, message, input_file_name, log_file_name, transform_name) FROM stdin;
\.


--
-- Data for Name: visit_dimension; Type: TABLE DATA; Schema: i2b2crcdata; Owner: i2b2crcdata
--

COPY i2b2crcdata.visit_dimension (encounter_num, patient_num, active_status_cd, start_date, end_date, inout_cd, location_cd, location_path, length_of_stay, visit_blob, update_date, download_date, import_date, sourcesystem_cd, upload_id) FROM stdin;
\.


--
-- Data for Name: crc_analysis_job; Type: TABLE DATA; Schema: i2b2hive; Owner: i2b2hive
--

COPY i2b2hive.crc_analysis_job (job_id, queue_name, status_type_id, domain_id, project_id, user_id, request_xml, create_date, update_date) FROM stdin;
\.


--
-- Data for Name: crc_db_lookup; Type: TABLE DATA; Schema: i2b2hive; Owner: i2b2hive
--

COPY i2b2hive.crc_db_lookup (c_domain_id, c_project_path, c_owner_id, c_db_fullschema, c_db_datasource, c_db_servertype, c_db_nicename, c_db_tooltip, c_comment, c_entry_date, c_change_date, c_status_cd) FROM stdin;
i2b2demo	/Demo/	@	i2b2crcdata	java:/QueryToolDemoDS	POSTGRESQL	Demo	\N	\N	\N	\N	\N
i2b2demo	/ACT/	@	public	java:/QueryToolDemoDS	POSTGRESQL	Demo	\N	\N	\N	\N	\N
\.


--
-- Data for Name: hive_cell_params; Type: TABLE DATA; Schema: i2b2hive; Owner: i2b2hive
--

COPY i2b2hive.hive_cell_params (id, datatype_cd, cell_id, param_name_cd, value, change_date, entry_date, changeby_char, status_cd) FROM stdin;
33	T	CRC	queryprocessor.jndi.queryinfolocal	ejb.querytool.QueryInfoLocal	\N	\N	\N	A
31	T	CRC	queryprocessor.jndi.querymanagerlocal	ejb.querytool.QueryManagerLocal	\N	\N	\N	A
37	T	CRC	queryprocessor.jndi.querymanagerremote	ejb.querytool.QueryManager	\N	\N	\N	A
61	T	ONT	applicationName	Ontology Cell	\N	\N	\N	A
63	T	CRC	applicationName	CRC Cell	\N	\N	\N	A
62	T	ONT	applicationVersion	1.7	\N	\N	\N	A
64	T	CRC	applicationVersion	1.7	\N	\N	\N	A
16	T	CRC	edu.harvard.i2b2.crc.analysis.queue.large.jobcheck.timemills	60000	\N	\N	\N	A
14	T	CRC	edu.harvard.i2b2.crc.analysis.queue.large.maxjobcount	1	\N	\N	\N	A
13	T	CRC	edu.harvard.i2b2.crc.analysis.queue.large.timeoutmills	43200000	\N	\N	\N	A
15	T	CRC	edu.harvard.i2b2.crc.analysis.queue.medium.jobcheck.timemills	60000	\N	\N	\N	A
12	T	CRC	edu.harvard.i2b2.crc.analysis.queue.medium.maxjobcount	4	\N	\N	\N	A
11	T	CRC	edu.harvard.i2b2.crc.analysis.queue.medium.timeoutmills	3000	\N	\N	\N	A
2	T	CRC	edu.harvard.i2b2.crc.delegate.ontology.operation.getchildren	/getChildren	\N	\N	\N	A
3	T	CRC	edu.harvard.i2b2.crc.delegate.ontology.operation.getmodifierinfo	/getModifierInfo	\N	\N	\N	A
1	T	CRC	edu.harvard.i2b2.crc.delegate.ontology.operation.getterminfo	/getTermInfo	\N	\N	\N	A
67	U	CRC	edu.harvard.i2b2.crc.delegate.ontology.url	/services/OntologyService	\N	\N	\N	A
28	T	CRC	edu.harvard.i2b2.crc.i2b2SocketServer	7070	\N	\N	\N	A
19	T	CRC	edu.harvard.i2b2.crc.jms.large.timeoutsec	43200	\N	\N	\N	A
18	T	CRC	edu.harvard.i2b2.crc.jms.medium.timeoutsec	14400	\N	\N	\N	A
17	T	CRC	edu.harvard.i2b2.crc.jms.small.timeoutsec	180	\N	\N	\N	A
22	T	CRC	edu.harvard.i2b2.crc.lockout.setfinderquery.count	7	\N	\N	\N	A
23	T	CRC	edu.harvard.i2b2.crc.lockout.setfinderquery.day	30	\N	\N	\N	A
24	T	CRC	edu.harvard.i2b2.crc.lockout.setfinderquery.zero.count	-1	\N	\N	\N	A
7	T	CRC	edu.harvard.i2b2.crc.pdo.paging.inputlist.minpercent	20	\N	\N	\N	A
8	T	CRC	edu.harvard.i2b2.crc.pdo.paging.inputlist.minsize	1	\N	\N	\N	A
6	T	CRC	edu.harvard.i2b2.crc.pdo.paging.iteration	100	\N	\N	\N	A
9	T	CRC	edu.harvard.i2b2.crc.pdo.paging.method	SUBDIVIDE_INPUT_METHOD 	\N	\N	\N	A
5	T	CRC	edu.harvard.i2b2.crc.pdo.paging.observation.size	7500	\N	\N	\N	A
10	T	CRC	edu.harvard.i2b2.crc.pdo.request.timeoutmills	600000	\N	\N	\N	A
21	T	CRC	edu.harvard.i2b2.crc.pm.serviceaccount.password	demouser	\N	\N	\N	A
20	T	CRC	edu.harvard.i2b2.crc.pm.serviceaccount.user	AGG_SERVICE_ACCOUNT	\N	\N	\N	A
66	T	CRC	edu.harvard.i2b2.crc.setfinder.querygenerator.version	1.7	\N	\N	\N	A
26	T	CRC	edu.harvard.i2b2.crc.setfinderquery.obfuscation.breakdowncount.sigma	1.6	\N	\N	\N	A
25	T	CRC	edu.harvard.i2b2.crc.setfinderquery.obfuscation.count.sigma	1.323	\N	\N	\N	A
27	T	CRC	edu.harvard.i2b2.crc.setfinderquery.obfuscation.minimum.value	3	\N	\N	\N	A
29	T	CRC	edu.harvard.i2b2.crc.setfinderquery.skiptemptable.maxconcept	40	\N	\N	\N	A
54	U	ONT	edu.harvard.i2b2.ontology.ws.crc.url	/services/QueryToolService	\N	\N	\N	A
59	T	ONT	edu.harvard.i2b2.ontology.ws.fr.attachmentname	cid	\N	\N	\N	A
58	T	ONT	edu.harvard.i2b2.ontology.ws.fr.filethreshold	4000	\N	\N	\N	A
60	T	ONT	edu.harvard.i2b2.ontology.ws.fr.operation	urn:recvfileRequest	\N	\N	\N	A
56	T	ONT	edu.harvard.i2b2.ontology.ws.fr.tempspace	/tmp	\N	\N	\N	A
57	T	ONT	edu.harvard.i2b2.ontology.ws.fr.timeout	10000	\N	\N	\N	A
55	U	ONT	edu.harvard.i2b2.ontology.ws.fr.url	/services/FRService/	\N	\N	\N	A
42	T	CRC	I2B2_MESSAGE_ERROR_AUTHENTICATION_FAILURE	Authentication failure.	\N	\N	\N	A
43	T	CRC	I2B2_MESSAGE_ERROR_INVALID_MESSAGE	Invalid message body	\N	\N	\N	A
48	T	CRC	I2B2_MESSAGE_STATUS_COMPLETED	COMPLETED	\N	\N	\N	A
46	T	CRC	I2B2_MESSAGE_STATUS_ERROR	ERROR	\N	\N	\N	A
47	T	CRC	I2B2_MESSAGE_STATUS_FINISHED	FINISHED	\N	\N	\N	A
49	T	CRC	I2B2_MESSAGE_STATUS_INCOMPLE	INCOMPLETE	\N	\N	\N	A
45	T	CRC	I2B2_MESSAGE_STATUS_PROCESSING	PROCESSING	\N	\N	\N	A
44	T	CRC	I2B2_MESSAGE_STATUS_QUEUED	QUEUED	\N	\N	\N	A
65	T	ONT	ontology.terminal.delimiter	true	\N	\N	\N	A
53	U	ONT	ontology.ws.pm.url	/services/PMService/getServices	\N	\N	\N	A
36	T	CRC	queryprocessor.jndi.pdoquerylocal	ejb.querytool.PdoQueryLocal	\N	\N	\N	A
30	T	CRC	queryprocessor.jndi.queryexecutormdblocal	ejb.querytool.QueryExecutorMDBLocal	\N	\N	\N	A
38	T	CRC	queryprocessor.jndi.queryexecutormdbremote	ejb.querytool.QueryExecutorMDB	\N	\N	\N	A
32	T	CRC	queryprocessor.jndi.querymasterlocal	ejb.querytool.QueryMasterLocal	\N	\N	\N	A
35	T	CRC	queryprocessor.jndi.queryresultlocal	ejb.querytool.QueryResultLocal	\N	\N	\N	A
34	T	CRC	queryprocessor.jndi.queryrunlocal	ejb.querytool.QueryRunLocal	\N	\N	\N	A
39	T	CRC	queryprocessor.jndi.queue.connectionfactory	ConnectionFactory	\N	\N	\N	A
41	T	CRC	queryprocessor.jndi.queue.executor_queue	queue/jms.querytool.QueryExecutor	\N	\N	\N	A
40	T	CRC	queryprocessor.jndi.queue.response_queue	queue/jms.querytool.QueryResponse	\N	\N	\N	A
4	T	CRC	queryprocessor.multifacttable	false	\N	\N	\N	A
50	U	CRC	queryprocessor.ws.ontology.url	/services/OntologyService/getTermInfo	\N	\N	\N	A
51	U	CRC	queryprocessor.ws.pm.url	/services/PMService/getServices	\N	\N	\N	A
52	U	WORK	workplace.ws.pm.url	/services/PMService/getServices	\N	\N	\N	A
68	U	IM	im.ws.pm.url	/services/PMService/getServices	\N	\N	\N	A
69	T	IM	im.checkPatientInProject	true	\N	\N	\N	A
70	T	IM	im.empi.service	none	\N	\N	\N	A
\.


--
-- Data for Name: im_db_lookup; Type: TABLE DATA; Schema: i2b2hive; Owner: i2b2hive
--

COPY i2b2hive.im_db_lookup (c_domain_id, c_project_path, c_owner_id, c_db_fullschema, c_db_datasource, c_db_servertype, c_db_nicename, c_db_tooltip, c_comment, c_entry_date, c_change_date, c_status_cd) FROM stdin;
i2b2demo	Demo/	@	i2b2imdata	java:/IMDemoDS	POSTGRESQL	IM	\N	\N	\N	\N	\N
\.


--
-- Data for Name: ont_db_lookup; Type: TABLE DATA; Schema: i2b2hive; Owner: i2b2hive
--

COPY i2b2hive.ont_db_lookup (c_domain_id, c_project_path, c_owner_id, c_db_fullschema, c_db_datasource, c_db_servertype, c_db_nicename, c_db_tooltip, c_comment, c_entry_date, c_change_date, c_status_cd) FROM stdin;
i2b2demo	Demo/	@	i2b2metadata	java:/OntologyDemoDS	POSTGRESQL	Metadata	\N	\N	\N	\N	\N
i2b2demo	ACT/	@	i2b2actdata	java:/OntologyDemoDS	POSTGRESQL	Metadata	\N	\N	\N	\N	\N
\.


--
-- Data for Name: work_db_lookup; Type: TABLE DATA; Schema: i2b2hive; Owner: i2b2hive
--

COPY i2b2hive.work_db_lookup (c_domain_id, c_project_path, c_owner_id, c_db_fullschema, c_db_datasource, c_db_servertype, c_db_nicename, c_db_tooltip, c_comment, c_entry_date, c_change_date, c_status_cd) FROM stdin;
i2b2demo	Demo/	@	i2b2workdata	java:/WorkplaceDemoDS	POSTGRESQL	Workplace	\N	\N	\N	\N	\N
i2b2demo	ACT/	@	public	java:/WorkplaceDemoDS	POSTGRESQL	Workplace	\N	\N	\N	\N	\N
\.


--
-- Data for Name: im_audit; Type: TABLE DATA; Schema: i2b2imdata; Owner: i2b2imdata
--

COPY i2b2imdata.im_audit (query_date, lcl_site, lcl_id, user_id, project_id, comments) FROM stdin;
\.


--
-- Data for Name: im_mpi_demographics; Type: TABLE DATA; Schema: i2b2imdata; Owner: i2b2imdata
--

COPY i2b2imdata.im_mpi_demographics (global_id, global_status, demographics, update_date, download_date, import_date, sourcesystem_cd, upload_id) FROM stdin;
100790915	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
100790926	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
100791247	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
101164949	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
101809330	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
102344360	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
102344362	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
102344364	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
102344367	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
102344369	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
102344370	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
102344373	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
102344376	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
102344379	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
102344381	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
102637795	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
102785439	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
102788263	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
103593382	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
103703039	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
103703072	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
103943507	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
103943509	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
104308528	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
104334898	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
105541340	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
105541343	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
105541501	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
105560546	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
105560548	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
105560549	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
105802853	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
105807520	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
105810956	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
105893324	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
106003404	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
990056789	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056790	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056791	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056792	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056793	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056794	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056795	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056796	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056797	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056798	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056799	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056800	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056801	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056802	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056803	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056804	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056805	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056806	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056807	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056808	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056809	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056810	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056811	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056812	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056813	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056814	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056815	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056816	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056817	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056818	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056819	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056820	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056821	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056822	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056823	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056824	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056825	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056826	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056827	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056828	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056829	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056830	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056831	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056832	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056833	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056834	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056835	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056836	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056837	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056838	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056839	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056840	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056841	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056842	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056843	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056844	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056845	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056846	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056847	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056848	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056849	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056850	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056851	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056852	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056853	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056854	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056855	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056856	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056857	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056858	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056859	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056860	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056861	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056862	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056863	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056864	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056865	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056866	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056867	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056868	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056869	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056870	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056871	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056872	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056873	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056874	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056875	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056876	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056877	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056878	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056879	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056880	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056881	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056882	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056883	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056884	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056885	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056886	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056887	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056888	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056889	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056890	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056891	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056892	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056893	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056894	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056895	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056896	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056897	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056898	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056899	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056900	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056901	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056902	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056903	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056904	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056905	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056906	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056907	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056908	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056909	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056910	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056911	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056912	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056913	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056914	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056915	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056916	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056917	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056918	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056919	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056920	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056921	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056922	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056923	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056924	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056925	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056926	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056927	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056928	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056929	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056930	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056931	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056932	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056933	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056934	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056935	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056936	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056937	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056938	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056939	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056940	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056941	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056942	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056943	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056944	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056945	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056946	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056947	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056948	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056949	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056950	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056951	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056952	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056953	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056954	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056955	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056956	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056957	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056958	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056959	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056960	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056961	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056962	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056963	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056964	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056965	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056966	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056967	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056968	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056969	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056970	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056971	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056972	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056973	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056974	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056975	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056976	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056977	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056978	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056979	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056980	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056981	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056982	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056983	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056984	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056985	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056986	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056987	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056988	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056989	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056990	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056991	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056992	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056993	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056994	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056995	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056996	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056997	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056998	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056999	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057000	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057001	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057002	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057003	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057004	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057005	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057006	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057007	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057008	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057009	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057010	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057011	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057012	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057013	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057014	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057015	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057016	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057017	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057018	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057019	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057020	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057021	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057022	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057023	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057024	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057025	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057026	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057027	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057028	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057029	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057030	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057031	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057032	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057033	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057034	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057035	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057036	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057037	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057038	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057039	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057040	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057041	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057042	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057043	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057044	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057045	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057046	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057047	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057048	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057049	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057050	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057051	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057052	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057053	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057054	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057055	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057056	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057057	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057058	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057059	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057060	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057061	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057062	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057063	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057064	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057065	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057066	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057067	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057068	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057069	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057070	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057071	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057072	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057073	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057074	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057075	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057076	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057077	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057078	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057079	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057080	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057081	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057082	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057083	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057084	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057085	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057086	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057087	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057088	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057089	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057090	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057091	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057092	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057093	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057094	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057095	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057096	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057097	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057098	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057099	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057100	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057101	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057102	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057103	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057104	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057105	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057106	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057107	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057108	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057109	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057110	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057111	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057112	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057113	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057114	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057115	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057116	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057117	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057118	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057119	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057120	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057121	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057122	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057123	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057124	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057125	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057126	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057127	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057128	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057129	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057130	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057131	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057132	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057133	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057134	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057135	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057136	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057137	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057138	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057139	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057140	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057141	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057142	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057143	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057144	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057145	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057146	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057147	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057148	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057149	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057150	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057151	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057152	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057153	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057154	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057155	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057156	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057157	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057158	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057159	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057160	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057161	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057162	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057163	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057164	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057165	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057166	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057167	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057168	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057169	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057170	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057171	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057172	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057173	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057174	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057175	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057176	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057177	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057178	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057179	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057180	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057181	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057182	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057183	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057184	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057185	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057186	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057187	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057188	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057189	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057190	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057191	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057192	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057193	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057194	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057195	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057196	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057197	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057198	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057199	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057200	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057201	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057202	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057203	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057204	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057205	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057206	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057207	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057208	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057209	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057210	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057211	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057212	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057213	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057214	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057215	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057216	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057217	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057218	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057219	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057220	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057221	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057222	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057223	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057224	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057225	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057226	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057227	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057228	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057229	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057230	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057231	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057232	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057233	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057234	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057235	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057236	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057237	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057238	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057239	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057240	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057241	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057242	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057243	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057244	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057245	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057246	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057247	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057248	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057249	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057250	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057251	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057252	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057253	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057254	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057255	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057256	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057257	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057258	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057259	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057260	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057261	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057262	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057263	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057264	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057265	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057266	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057267	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057268	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057269	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057270	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057271	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057272	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057273	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057274	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057275	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057276	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057277	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057278	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057279	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057280	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057281	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057282	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057283	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057284	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057285	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057286	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057287	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057288	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057289	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057290	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057291	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057292	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057293	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057294	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057295	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057296	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057297	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057298	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057299	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057300	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057301	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057302	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057303	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057304	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057305	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057306	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057307	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057308	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057309	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057310	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057311	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057312	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057313	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057314	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057315	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057316	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057317	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057318	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057319	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057320	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057321	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057322	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057323	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057324	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057325	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057326	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057327	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057328	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057329	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057330	A	\N	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
\.


--
-- Data for Name: im_mpi_mapping; Type: TABLE DATA; Schema: i2b2imdata; Owner: i2b2imdata
--

COPY i2b2imdata.im_mpi_mapping (global_id, lcl_site, lcl_id, lcl_status, update_date, download_date, import_date, sourcesystem_cd, upload_id) FROM stdin;
100790915	Hospital-1_E	BVFFC8U395LIG5A20IQGF5VPBQ	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
100790915	Hospital-2_E	2ITNSBR835A6TBT5UH4RQOIV09	A	2008-07-24 11:03:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
100790915	Master_Index	100790915	A	2008-07-24 11:03:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
100790915	Hospital-5	3000001831	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
100790915	Hospital-7	S500003061	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
100790915	Hospital-8	U500004021	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
100790915	Hospital-6	4000002011	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
100790926	Hospital-1	11489986	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
100790926	Hospital-2	01164897	A	2012-03-10 09:19:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
100790926	Master_Index	100790926	A	2012-03-10 09:19:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
100790926	Hospital-5	3000001832	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
100790926	Hospital-7	S500003062	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
100790926	Hospital-8	U500004022	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
100790926	Hospital-6	4000002012	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
100791247	Hospital-1	11490505	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
100791247	Hospital-2	01165476	A	2012-04-10 14:41:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
100791247	Master_Index	100791247	A	2012-04-10 14:41:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
100791247	Hospital-5	3000001834	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
100791247	Hospital-7	S500003064	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
100791247	Hospital-6	4000002014	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
101164949	Hospital-1	00000117	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
101164949	Hospital-2_E	AJ10DO3JG0L3M3KLPT1SGD79JD	A	2006-04-10 14:31:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
101164949	Master_Index	101164949	A	2006-04-10 14:31:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
101164949	Hospital-5	3000001838	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
101164949	Hospital-7	S500003068	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
101164949	Hospital-8	U500004028	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
101164949	Hospital-6	4000002018	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
101809330	Hospital-1_E	A2HB8LGT048UV9JOCJ92D5JOOO	A	2011-08-08 14:27:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
101809330	Hospital-2	01800290	A	2011-08-08 14:27:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
101809330	Master_Index	101809330	A	2011-08-08 14:27:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
101809330	Hospital-5	3000001845	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
101809330	Hospital-7	S500003075	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
101809330	Hospital-8	U500004035	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
101809330	Hospital-6	4000002025	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344360	Hospital-1	17028580	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344360	Hospital-2	01954309	A	2010-05-17 09:35:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344360	Hospital-3_E	3VED4MPC6VM7!8GANM9E9RE5VM	A	2010-05-17 09:35:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344360	Master_Index	102344360	A	2010-05-17 09:35:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344360	Hospital-4	00001003	A	2010-05-17 09:35:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344360	Hospital-7	S500003076	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344360	Hospital-8	U500004036	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344360	Hospital-6	4000002026	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344362	Hospital-1	17028598	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344362	Hospital-2_E	643LL7U2ETFUDJ7P1D7BLJCGA!	A	2007-10-01 13:51:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344362	Hospital-3_E	59C60C8U4SHIEB3D416ISKUVJ8	A	2007-10-01 13:51:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344362	Master_Index	102344362	A	2007-10-01 13:51:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344362	Hospital-5	3000001848	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344362	Hospital-7	S500003078	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344362	Hospital-8	U500004038	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344362	Hospital-6	4000002028	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344364	Hospital-1	17028630	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344364	Hospital-2	01954385	A	2012-07-25 15:33:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344364	Hospital-3	252307	A	2012-07-25 15:33:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344364	Master_Index	102344364	A	2012-07-25 15:33:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344364	Hospital-5	3000001853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344364	Hospital-8	U500004043	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344364	Hospital-6	4000002033	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344367	Hospital-1	17028655	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344367	Hospital-2	01954387	A	2006-04-11 11:13:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344367	Hospital-3_E	EC03V1RTVE6B!88BHA8LEM0CVV	A	2006-04-11 11:13:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344367	Master_Index	102344367	A	2006-04-11 11:13:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344367	Hospital-5	3000001857	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344367	Hospital-7	S500003087	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344367	Hospital-8	U500004047	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344369	Hospital-1	17028473	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344369	Hospital-2	01954124	A	2006-04-11 11:14:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344369	Hospital-3_E	48H0V6FFMLSUNFU1TJT6CT3R76	A	2006-04-11 11:14:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344369	Master_Index	102344369	A	2006-04-11 11:14:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344369	Hospital-5	3000001859	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344369	Hospital-7	S500003089	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344369	Hospital-8	U500004049	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344369	Hospital-6	4000002039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344370	Hospital-1_E	C7UNJSOKKAIBG7LHJMVCSS3C5!	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344370	Hospital-2	01954388	A	2006-04-11 11:15:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344370	Hospital-3_E	4VTSH27PC1SS2DISDJNH8LNTJV	A	2006-04-11 11:15:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344370	Master_Index	102344370	A	2006-04-11 11:15:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344370	Hospital-4	00001005	A	2006-04-11 11:15:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344370	Hospital-5	3000001863	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344370	Hospital-8	U500004053	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344370	Hospital-6	4000002043	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344373	Hospital-1	17028671	A	2006-04-11 11:15:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344373	Hospital-2_E	C8JTCV4683RJC5GP4FUPN28R3S	A	2006-04-11 11:15:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344373	Hospital-3	252312	A	2006-04-11 11:15:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344373	Master_Index	102344373	A	2006-04-11 11:15:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344373	Hospital-5	3000001865	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344373	Hospital-7	S500003095	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344373	Hospital-8	U500004055	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344373	Hospital-6	4000002045	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344376	Hospital-1	17028705	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344376	Hospital-2_E	B5Q0ULMUEQN2DCB7Q2QTGIKDU2	A	2006-04-11 11:16:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344376	Hospital-3	252313	A	2006-04-11 11:16:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344376	Master_Index	102344376	A	2006-04-11 11:16:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344376	Hospital-5	3000001867	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344376	Hospital-7	S500003097	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344376	Hospital-8	U500004057	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344379	Hospital-1	17028481	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344379	Hospital-2	01954285	A	2006-04-11 11:16:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344379	Hospital-3	252308	A	2006-04-11 11:16:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344379	Master_Index	102344379	A	2006-04-11 11:16:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344379	Hospital-5	3000001870	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344379	Hospital-7	S500003100	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344379	Hospital-8	U500004060	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344379	Hospital-6	4000002050	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344381	Hospital-1	17028747	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344381	Hospital-2	01954550	A	2008-12-02 16:36:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344381	Hospital-3_E	1C383QGJ5RDHT9FEK7UJT3V0ND	A	2008-12-02 16:36:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344381	Master_Index	102344381	A	2008-12-02 16:36:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344381	Hospital-4	00001006	A	2008-12-02 16:36:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102344381	Hospital-5	3000001872	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344381	Hospital-7	S500003102	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344381	Hospital-8	U500004062	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102344381	Hospital-6	4000002052	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102637795	Hospital-1	18092957	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102637795	Hospital-2	01722840	A	2008-07-28 15:07:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102637795	Master_Index	102637795	A	2008-07-28 15:07:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102637795	Hospital-5	3000001874	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102637795	Hospital-7	S500003104	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102637795	Hospital-6	4000002054	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102785439	Hospital-1_E	69RI1ABH0Q6LO3HTML79HQF98M	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102785439	Hospital-2	02160313	A	2006-04-10 14:38:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102785439	Master_Index	102785439	A	2006-04-10 14:38:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102785439	Hospital-7	S500003116	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102785439	Hospital-8	U500004076	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102785439	Hospital-6_E	3O4UBEPK5RKJR68JL97GPG8BC5	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102788263	Hospital-1	18658583	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102788263	Hospital-2_E	B0T96NJTTVCECAEDTB09I37G67	A	2009-05-15 14:30:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102788263	Master_Index	102788263	A	2009-05-15 14:30:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
102788263	Hospital-5	3000001891	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102788263	Hospital-7	S500003121	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102788263	Hospital-8	U500004081	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
102788263	Hospital-6	4000002071	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103593382	Hospital-1	11489960	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103593382	Hospital-2	01164891	A	2009-04-20 15:11:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
103593382	Hospital-3_E	29LPSF4019FJR2CKFOVV23QOPA	A	2009-04-20 15:11:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
103593382	Master_Index	103593382	A	2009-04-20 15:11:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
103593382	Hospital-4	01055419	A	2009-04-20 15:11:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
103593382	Hospital-5	3000001894	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103593382	Hospital-7	S500003124	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103593382	Hospital-6	4000002074	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103703039	Hospital-1	20722294	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103703039	Hospital-2	02408012	A	2011-03-21 15:30:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
103703039	Hospital-3	346657	A	2011-03-21 15:30:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
103703039	Master_Index	103703039	A	2011-03-21 15:30:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
103703039	Hospital-5	3000001903	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103703039	Hospital-8	U500004093	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103703039	Hospital-6	4000002083	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103703072	Hospital-1	20722302	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103703072	Hospital-2	02408022	A	2012-11-12 15:19:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
103703072	Hospital-3	345830	A	2012-11-12 15:19:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
103703072	Master_Index	103703072	A	2012-11-12 15:19:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
103703072	Hospital-7	S500003136	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103703072	Hospital-8	U500004096	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103703072	Hospital-6	4000002086	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103943507	Hospital-1	2000001987	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103943507	Master_Index	103943507	A	2009-10-23 15:35:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
103943507	Hospital-5	3000001847	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103943507	Hospital-7	S500003077	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103943507	Hospital-8	U500004037	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103943509	Hospital-1	2000002090	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103943509	Master_Index	103943509	A	2009-10-23 15:35:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
103943509	Hospital-5	3000001950	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103943509	Hospital-7	S500003180	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103943509	Hospital-8	U500004140	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
103943509	Hospital-6	4000002130	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
104308528	Hospital-1	00000091	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
104308528	Hospital-2_E	4GTLSO9CP9DJ86FCV0QJ2E25H5	A	2010-03-16 08:39:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
104308528	Master_Index	104308528	A	2010-03-16 08:39:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
104308528	Hospital-5	3000001907	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
104308528	Hospital-7	S500003137	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
104308528	Hospital-8	U500004097	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
104334898	Hospital-1_E	55NI0PG4FE1K45FTFS9HA983IG	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
104334898	Hospital-2	01164890	A	2012-03-16 14:01:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
104334898	Hospital-3	299566	A	2012-03-16 14:01:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
104334898	Master_Index	104334898	A	2012-03-16 14:01:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
104334898	Hospital-5	3000001909	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
104334898	Hospital-7	S500003139	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
104334898	Hospital-8	U500004099	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
104334898	Hospital-6	4000002089	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105541340	Hospital-1	2000002054	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105541340	Master_Index	105541340	A	2009-10-23 14:57:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105541340	Hospital-5	4745300	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105541340	Hospital-7	S500003144	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105541340	Hospital-6	4000002094	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105541343	Hospital-1	2000002056	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105541343	Master_Index	105541343	A	2009-10-29 22:49:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105541343	Hospital-5_E	AUFRP61U0FK6TFILC8I0CHA957	A	2009-10-29 22:49:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105541343	Hospital-7	S500003146	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105541343	Hospital-8	U500004106	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105541343	Hospital-6	4000002096	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105541501	Hospital-1	2000002059	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105541501	Master_Index	105541501	A	2009-10-28 22:44:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105541501	Hospital-5	4745303	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105541501	Hospital-7_E	C6KC9GBNAVJED24N3SL3QHF7HQ	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105541501	Hospital-8	U500004109	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105541501	Hospital-6	4000002099	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105560546	Master_Index	105560546	A	2009-08-19 11:49:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105560546	Hospital-5_E	DNUTM3P012I4K1RIMJTV325M5G	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105560546	Hospital-7	S500003155	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105560546	Hospital-8	U500004115	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105560546	Hospital-6	4000002105	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105560548	Hospital-1	2000002067	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105560548	Master_Index	105560548	A	2009-08-19 11:51:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105560548	Hospital-5	4745321	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105560548	Hospital-7	S500003157	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105560548	Hospital-8	U500004117	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105560549	Hospital-1	2000002068	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105560549	Master_Index	105560549	A	2009-08-19 11:52:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105560549	Hospital-5_E	59TLK285NQ49!D76D6DQO8IME8	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105560549	Hospital-7	S500003158	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105560549	Hospital-8	U500004118	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105560549	Hospital-6	4000002108	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105802853	Hospital-1	24492902	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105802853	Hospital-2	02847863	A	2010-01-07 13:04:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105802853	Hospital-3_E	82NGIU1EMUVKEED33Q4726OVAG	A	2010-01-07 13:04:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105802853	Master_Index	105802853	A	2010-01-07 13:04:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105802853	Hospital-5	3000001938	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105802853	Hospital-7	S500003168	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105802853	Hospital-8	U500004128	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105802853	Hospital-6	4000002118	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105807520	Hospital-1	24528291	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105807520	Hospital-2	02848903	A	2012-10-18 07:26:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105807520	Hospital-3	477778	A	2012-10-18 07:26:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105807520	Master_Index	105807520	A	2012-10-18 07:26:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105807520	Hospital-5	3000001941	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105807520	Hospital-7	S500003171	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105807520	Hospital-8	U500004131	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105807520	Hospital-6	4000002121	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105810956	Hospital-1	24528580	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105810956	Hospital-2	02849661	A	2010-01-11 10:39:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105810956	Hospital-3	477779	A	2010-01-11 10:39:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105810956	Master_Index	105810956	A	2010-01-11 10:39:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105810956	Hospital-5	3000001943	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105810956	Hospital-8	U500004133	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105810956	Hospital-6	4000002123	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105893324	Hospital-1_E	AS6RQRP6604HMDJSLT1GT3JLSP	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105893324	Hospital-2	02867887	A	2013-01-03 14:32:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105893324	Hospital-3_E	5JSV828EKSUQK6GOD60HS2JL4F	A	2013-01-03 14:32:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105893324	Master_Index	105893324	A	2013-01-03 14:32:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
105893324	Hospital-5	3000001948	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105893324	Hospital-7	S500003178	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105893324	Hospital-8	U500004138	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
105893324	Hospital-6	4000002128	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
106003404	Hospital-1	17028606	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
106003404	Hospital-2	01954311	A	2010-06-03 07:45:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
106003404	Hospital-3	521660	A	2010-06-03 07:45:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
106003404	Master_Index	106003404	A	2010-06-03 07:45:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
106003404	Hospital-4	00001004	A	2010-06-03 07:45:00	2013-01-22 10:15:00	\N	DEMO_I2B2	\N
106003404	Hospital-5	3000001949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
106003404	Hospital-7	S500003179	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
106003404	Hospital-8	U500004139	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
106003404	Hospital-6	4000002129	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_I2B2	\N
990056887	Hospital-8_E	1RRSFOJ3LFQ6EAER08G8TI57CR	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056888	Hospital-1	2000001961	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056889	Hospital-1	2000001962	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056890	Hospital-1	2000001963	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056891	Hospital-1	2000001964	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056892	Hospital-1	2000001965	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056893	Hospital-1	2000001966	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056894	Hospital-1	2000001967	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056895	Hospital-1	2000001968	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056896	Hospital-1	2000001969	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056897	Hospital-1	2000001970	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056898	Hospital-1	2000001973	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056899	Hospital-1	2000001977	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056900	Hospital-1	2000001979	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056901	Hospital-1	2000001980	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056902	Hospital-1	2000001981	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056903	Hospital-1	2000001982	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056904	Hospital-1	2000001983	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056905	Hospital-1	2000001984	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056906	Hospital-1	2000001989	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056907	Hospital-1	2000001990	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056908	Hospital-1	2000001991	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056909	Hospital-1	2000001994	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056910	Hospital-1	2000001996	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056911	Hospital-1	2000001998	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056912	Hospital-1	2000002000	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056913	Hospital-1	2000002001	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056914	Hospital-1	2000002002	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056915	Hospital-1	2000002004	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056916	Hospital-1	2000002006	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056917	Hospital-1	2000002008	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056918	Hospital-1	2000002009	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056919	Hospital-1	2000002011	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056920	Hospital-1	2000002013	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056921	Hospital-1	2000002016	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056922	Hospital-1	2000002017	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056923	Hospital-1	2000002018	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056924	Hospital-1	2000002019	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056925	Hospital-1	2000002021	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056926	Hospital-1	2000002022	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056927	Hospital-1	2000002023	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056928	Hospital-1	2000002024	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056929	Hospital-1	2000002027	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056930	Hospital-1	2000002028	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056931	Hospital-1	2000002029	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056932	Hospital-1	2000002030	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056933	Hospital-1	2000002032	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056934	Hospital-1	2000002033	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056935	Hospital-1	2000002036	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056936	Hospital-1	2000002037	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056937	Hospital-1	2000002038	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056938	Hospital-1	2000002039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056939	Hospital-1	2000002040	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056940	Hospital-1	2000002041	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056941	Hospital-1	2000002042	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056942	Hospital-1	2000002044	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056943	Hospital-1	2000002050	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056944	Hospital-1	2000002051	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056945	Hospital-1	2000002052	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056946	Hospital-1	2000002053	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056947	Hospital-1	2000002057	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056948	Hospital-1	2000002058	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056949	Hospital-1	2000002060	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056950	Hospital-1	2000002061	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056951	Hospital-1	2000002062	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056952	Hospital-1	2000002063	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056953	Hospital-1	2000002064	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056954	Hospital-1	2000002066	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056955	Hospital-1	2000002069	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056956	Hospital-1	2000002070	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056957	Hospital-1	2000002071	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056958	Hospital-1	2000002072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056959	Hospital-1	2000002073	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056960	Hospital-1	2000002074	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056961	Hospital-1	2000002076	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056962	Hospital-1	2000002077	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056963	Hospital-1	2000002079	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056964	Hospital-1	2000002080	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056965	Hospital-1	2000002082	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056966	Hospital-1	2000002084	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056967	Hospital-1	2000002086	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056968	Hospital-1	2000002087	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056969	Hospital-1	2000002091	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056970	Hospital-1	2000002092	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056971	Hospital-1	2000002093	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056972	Hospital-1	2000002094	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056973	Hospital-5	3000001821	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056974	Hospital-5	3000001822	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056975	Hospital-5	3000001823	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056976	Hospital-5	3000001824	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056977	Hospital-5	3000001825	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056978	Hospital-5	3000001827	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056979	Hospital-5	3000001828	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056980	Hospital-5	3000001829	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056981	Hospital-5	3000001830	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056982	Hospital-5	3000001833	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056983	Hospital-5	3000001835	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056984	Hospital-5	3000001837	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056985	Hospital-5	3000001839	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056986	Hospital-5	3000001841	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056987	Hospital-5	3000001842	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056988	Hospital-5	3000001843	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056989	Hospital-5	3000001844	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056990	Hospital-5	3000001849	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056991	Hospital-5	3000001850	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056992	Hospital-5	3000001851	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056993	Hospital-5	3000001852	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056994	Hospital-5	3000001855	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056995	Hospital-5	3000001858	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056996	Hospital-5	3000001860	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056997	Hospital-5	3000001861	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056998	Hospital-5	3000001862	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990056999	Hospital-5	3000001864	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057000	Hospital-5	3000001868	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057001	Hospital-5	3000001869	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057002	Hospital-5	3000001871	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057003	Hospital-5	3000001873	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057004	Hospital-5	3000001875	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057005	Hospital-5	3000001877	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057006	Hospital-5	3000001878	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057007	Hospital-5	3000001879	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057008	Hospital-5	3000001881	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057009	Hospital-5	3000001882	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057010	Hospital-5	3000001883	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057011	Hospital-5	3000001884	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057012	Hospital-5	3000001885	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057013	Hospital-5	3000001887	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057014	Hospital-5	3000001888	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057015	Hospital-5	3000001889	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057016	Hospital-5	3000001890	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057017	Hospital-5	3000001892	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057018	Hospital-5	3000001893	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057019	Hospital-5	3000001895	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057020	Hospital-5	3000001897	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057021	Hospital-5	3000001898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057022	Hospital-5	3000001899	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057023	Hospital-5	3000001900	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057024	Hospital-5	3000001901	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057025	Hospital-5	3000001904	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057026	Hospital-5	3000001905	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057027	Hospital-5	3000001908	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057028	Hospital-5	3000001910	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057029	Hospital-5	3000001911	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057030	Hospital-5	3000001912	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057031	Hospital-5	3000001913	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057032	Hospital-5	3000001915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057033	Hospital-5	3000001917	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057034	Hospital-5	3000001918	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057035	Hospital-5	3000001920	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057036	Hospital-5	3000001921	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057037	Hospital-5	3000001922	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057038	Hospital-5	3000001923	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057039	Hospital-5	3000001924	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057040	Hospital-5	3000001929	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057041	Hospital-5	3000001930	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057042	Hospital-5	3000001931	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057043	Hospital-5	3000001932	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057044	Hospital-5	3000001933	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057045	Hospital-5	3000001934	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057046	Hospital-5	3000001935	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057047	Hospital-5	3000001937	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057048	Hospital-5	3000001939	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057049	Hospital-5	3000001940	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057050	Hospital-5	3000001942	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057051	Hospital-5	3000001944	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057052	Hospital-5	3000001945	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057053	Hospital-5	3000001947	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057054	Hospital-5	3000001951	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057055	Hospital-5	3000001952	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057056	Hospital-5	3000001953	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057057	Hospital-5	3000001954	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057058	Hospital-8_E	3ENVRHAPMRJA56Q6JM596GTQK!	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057059	Hospital-6	4000002001	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057060	Hospital-6	4000002002	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057061	Hospital-6	4000002003	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057062	Hospital-6	4000002004	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057063	Hospital-6	4000002005	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057064	Hospital-6	4000002006	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057065	Hospital-6	4000002008	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057066	Hospital-6	4000002009	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057067	Hospital-6	4000002010	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057068	Hospital-6	4000002013	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057069	Hospital-6	4000002015	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057070	Hospital-6	4000002016	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057071	Hospital-6	4000002019	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057072	Hospital-6	4000002020	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057073	Hospital-6	4000002021	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057074	Hospital-6	4000002022	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057075	Hospital-6	4000002023	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057076	Hospital-6	4000002024	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057077	Hospital-6	4000002029	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057078	Hospital-6	4000002030	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057079	Hospital-6	4000002031	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057080	Hospital-6	4000002032	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057081	Hospital-6	4000002034	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057082	Hospital-6	4000002035	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057083	Hospital-6	4000002036	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057084	Hospital-6	4000002038	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057085	Hospital-6	4000002040	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057086	Hospital-6	4000002041	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057087	Hospital-6	4000002042	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057088	Hospital-6	4000002044	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057089	Hospital-6	4000002046	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057090	Hospital-6	4000002048	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057091	Hospital-6	4000002049	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057092	Hospital-6	4000002051	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057093	Hospital-6	4000002053	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057094	Hospital-6	4000002055	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057095	Hospital-6	4000002056	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057096	Hospital-6	4000002058	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057097	Hospital-6	4000002059	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057098	Hospital-6	4000002060	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057099	Hospital-6	4000002061	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057100	Hospital-6	4000002062	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057101	Hospital-6	4000002063	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057102	Hospital-6	4000002064	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057103	Hospital-6	4000002065	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057104	Hospital-6	4000002068	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057105	Hospital-6	4000002069	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057106	Hospital-6	4000002070	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057107	Hospital-6	4000002072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057108	Hospital-6	4000002073	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057109	Hospital-6	4000002075	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057110	Hospital-6	4000002076	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057111	Hospital-6	4000002078	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057112	Hospital-6	4000002079	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057113	Hospital-6	4000002080	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057114	Hospital-6	4000002081	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057115	Hospital-6	4000002082	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057116	Hospital-6	4000002084	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057117	Hospital-6	4000002085	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057118	Hospital-6	4000002088	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057119	Hospital-6	4000002091	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057120	Hospital-6	4000002092	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057121	Hospital-6	4000002093	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057122	Hospital-6	4000002095	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057123	Hospital-6	4000002098	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057124	Hospital-6	4000002100	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057125	Hospital-6	4000002101	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057126	Hospital-6	4000002102	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057127	Hospital-6	4000002103	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057128	Hospital-6	4000002104	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057129	Hospital-6	4000002109	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057130	Hospital-6	4000002110	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057131	Hospital-6	4000002111	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057132	Hospital-6	4000002112	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057133	Hospital-6	4000002113	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057134	Hospital-6	4000002114	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057135	Hospital-6	4000002115	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057136	Hospital-6	4000002116	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057137	Hospital-6	4000002119	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057138	Hospital-6	4000002120	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057139	Hospital-6	4000002122	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057140	Hospital-6	4000002124	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057141	Hospital-6	4000002125	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057142	Hospital-6	4000002126	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057143	Hospital-6	4000002131	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057144	Hospital-6	4000002133	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057145	Hospital-6	4000002134	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057146	Hospital-7_E	4CUUFEBOV648G1U5N5GLP15GF7	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057147	Hospital-1_E	52JC97QSN3ARJ7BR6CKM5QC6ME	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057148	Hospital-8_E	61N65R47H747021F2N0PSUKI4J	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057149	Hospital-5_E	8E6JQCMEQ8NUNATMH6ACQIOQ4O	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057150	Hospital-7_E	8JF8NPQNHKU3BDUTUNK9PGB927	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057151	Hospital-1_E	AH0QL9668FSAB7AATOO28EOP46	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057152	Hospital-6_E	AKH21TVH2JUV!DGEELPIC8LA9F	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057153	Hospital-7_E	AV2VJ0VVTM5AT3LJC8OI3C5V8J	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057154	Hospital-5_E	BCTCRLHSKGBMQ7P90330VJKFAG	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057155	Hospital-1_E	BTM9MH1JJGAVBFKEOQ75J1F7L!	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057156	Hospital-6_E	C0V5BDD0VSNVG91VGCGEU4RC2D	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057157	Hospital-8_E	CQR959QOAGJUT94J1LD2INLL17	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057158	Hospital-5_E	DON2RP778SNOU95OS1BGLN4EV0	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057159	Hospital-5_E	E309EB1I0PB0!AEMA1OUJ260TD	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057160	Hospital-6_E	E5Q6I8P09I1R9BHO8FAKITU0QC	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057161	Hospital-1_E	F9S8MS240CMC38ND2NSA33AG6A	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057162	Hospital-7	S500003051	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057163	Hospital-7	S500003052	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057164	Hospital-7	S500003054	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057165	Hospital-7	S500003055	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057166	Hospital-7	S500003056	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057167	Hospital-7	S500003057	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057168	Hospital-7	S500003058	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057169	Hospital-7	S500003059	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057170	Hospital-7	S500003060	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057171	Hospital-7	S500003065	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057172	Hospital-7	S500003066	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057173	Hospital-7	S500003069	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057174	Hospital-7	S500003070	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057175	Hospital-7	S500003071	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057176	Hospital-7	S500003072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057177	Hospital-7	S500003074	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057178	Hospital-7	S500003079	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057179	Hospital-7	S500003080	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057180	Hospital-7	S500003081	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057181	Hospital-7	S500003082	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057182	Hospital-7	S500003084	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057183	Hospital-7	S500003085	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057184	Hospital-7	S500003086	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057185	Hospital-7	S500003088	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057186	Hospital-7	S500003091	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057187	Hospital-7	S500003092	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057188	Hospital-7	S500003094	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057189	Hospital-7	S500003096	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057190	Hospital-7	S500003098	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057191	Hospital-7	S500003099	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057192	Hospital-7	S500003101	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057193	Hospital-7	S500003105	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057194	Hospital-7	S500003106	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057195	Hospital-7	S500003107	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057196	Hospital-7	S500003108	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057197	Hospital-7	S500003109	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057198	Hospital-7	S500003110	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057199	Hospital-7	S500003111	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057200	Hospital-7	S500003112	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057201	Hospital-7	S500003114	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057202	Hospital-7	S500003115	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057203	Hospital-7	S500003117	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057204	Hospital-7	S500003118	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057205	Hospital-7	S500003119	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057206	Hospital-7	S500003120	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057207	Hospital-7	S500003122	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057208	Hospital-7	S500003125	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057209	Hospital-7	S500003126	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057210	Hospital-7	S500003127	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057211	Hospital-7	S500003129	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057212	Hospital-7	S500003130	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057213	Hospital-7	S500003131	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057214	Hospital-7	S500003132	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057215	Hospital-7	S500003134	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057216	Hospital-7	S500003135	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057217	Hospital-7	S500003138	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057218	Hospital-7	S500003140	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057219	Hospital-7	S500003141	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057220	Hospital-7	S500003142	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057221	Hospital-7	S500003145	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057222	Hospital-7	S500003147	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057223	Hospital-7	S500003148	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057224	Hospital-7	S500003150	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057225	Hospital-7	S500003151	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057226	Hospital-7	S500003152	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057227	Hospital-7	S500003154	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057228	Hospital-7	S500003156	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057229	Hospital-7	S500003159	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057230	Hospital-7	S500003160	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057231	Hospital-7	S500003161	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057232	Hospital-7	S500003162	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057233	Hospital-7	S500003164	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057234	Hospital-7	S500003165	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057235	Hospital-7	S500003166	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057236	Hospital-7	S500003167	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057237	Hospital-7	S500003169	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057238	Hospital-7	S500003170	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057239	Hospital-7	S500003172	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057240	Hospital-7	S500003174	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057241	Hospital-7	S500003175	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057242	Hospital-7	S500003176	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057243	Hospital-7	S500003177	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057244	Hospital-7	S500003181	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057245	Hospital-7	S500003182	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057246	Hospital-7	S500003184	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057247	Hospital-8	U500004011	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057248	Hospital-8	U500004012	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057249	Hospital-8	U500004013	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057250	Hospital-8	U500004015	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057251	Hospital-8	U500004016	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057252	Hospital-8	U500004017	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057253	Hospital-8	U500004018	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057254	Hospital-8	U500004019	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057255	Hospital-8	U500004020	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057256	Hospital-8	U500004023	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057257	Hospital-8	U500004025	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057258	Hospital-8	U500004026	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057259	Hospital-8	U500004027	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057260	Hospital-8	U500004029	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057261	Hospital-8	U500004030	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057262	Hospital-8	U500004031	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057263	Hospital-8	U500004032	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057264	Hospital-8	U500004033	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057265	Hospital-8	U500004039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057266	Hospital-8	U500004040	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057267	Hospital-8	U500004041	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057268	Hospital-8	U500004042	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057269	Hospital-8	U500004046	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057270	Hospital-8	U500004048	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057271	Hospital-8	U500004050	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057272	Hospital-8	U500004051	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057273	Hospital-8	U500004052	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057274	Hospital-8	U500004056	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057275	Hospital-8	U500004058	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057276	Hospital-8	U500004059	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057277	Hospital-8	U500004061	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057278	Hospital-8	U500004063	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057279	Hospital-8	U500004065	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057280	Hospital-8	U500004066	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057281	Hospital-8	U500004067	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057282	Hospital-8	U500004068	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057283	Hospital-8	U500004069	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057284	Hospital-8	U500004070	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057285	Hospital-8	U500004071	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057286	Hospital-8	U500004072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057287	Hospital-8	U500004073	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057288	Hospital-8	U500004075	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057289	Hospital-8	U500004078	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057290	Hospital-8	U500004079	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057291	Hospital-8	U500004080	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057292	Hospital-8	U500004082	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057293	Hospital-8	U500004083	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057294	Hospital-8	U500004085	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057295	Hospital-8	U500004086	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057296	Hospital-8	U500004087	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057297	Hospital-8	U500004088	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057298	Hospital-8	U500004089	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057299	Hospital-8	U500004090	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057300	Hospital-8	U500004091	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057301	Hospital-8	U500004092	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057302	Hospital-8	U500004095	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057303	Hospital-8	U500004098	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057304	Hospital-8	U500004100	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057305	Hospital-8	U500004101	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057306	Hospital-8	U500004102	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057307	Hospital-8	U500004103	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057308	Hospital-8	U500004105	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057309	Hospital-8	U500004107	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057310	Hospital-8	U500004108	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057311	Hospital-8	U500004110	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057312	Hospital-8	U500004111	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057313	Hospital-8	U500004112	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057314	Hospital-8	U500004116	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057315	Hospital-8	U500004119	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057316	Hospital-8	U500004120	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057317	Hospital-8	U500004121	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057318	Hospital-8	U500004122	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057319	Hospital-8	U500004123	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057320	Hospital-8	U500004125	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057321	Hospital-8	U500004126	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057322	Hospital-8	U500004127	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057323	Hospital-8	U500004129	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057324	Hospital-8	U500004130	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057325	Hospital-8	U500004132	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057326	Hospital-8	U500004135	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057327	Hospital-8	U500004136	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057328	Hospital-8	U500004137	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057329	Hospital-8	U500004141	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
990057330	Hospital-8	U500004143	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
\.


--
-- Data for Name: im_project_patients; Type: TABLE DATA; Schema: i2b2imdata; Owner: i2b2imdata
--

COPY i2b2imdata.im_project_patients (project_id, global_id, patient_project_status, update_date, download_date, import_date, sourcesystem_cd, upload_id) FROM stdin;
demo	100790915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	100790926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	100791247	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	101164949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	101809330	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	102344360	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	102344362	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	102344364	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	102344367	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	102344369	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	102344370	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	102344373	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	102344376	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	102344379	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	102344381	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	102637795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	102785439	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	102788263	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	103593382	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	103703039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	103703072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	103943507	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	103943509	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	104308528	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	104334898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	105541340	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	105541343	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	105541501	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	105560546	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	105560548	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	105560549	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	105802853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	105807520	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	105810956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	105893324	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	106003404	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo	990056789	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056790	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056791	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056792	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056793	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056794	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056796	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056797	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056798	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056799	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056800	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056801	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056802	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056803	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056804	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056805	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056806	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056807	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056808	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056809	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056810	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056811	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056812	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056813	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056814	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056815	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056816	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056817	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056818	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056819	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056820	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056821	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056822	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056823	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056824	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056825	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056826	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056827	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056828	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056829	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056830	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056831	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056832	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056833	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056834	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056835	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056836	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056837	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056838	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056839	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056840	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056841	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056842	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056843	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056844	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056845	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056846	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056847	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056848	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056849	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056850	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056851	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056852	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056854	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056855	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056856	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056857	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056858	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056859	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056860	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056861	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056862	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056863	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056864	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056865	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056866	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056867	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056868	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056869	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056870	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056871	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056872	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056873	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056874	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056875	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056876	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056877	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056878	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056879	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056880	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056881	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056882	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056883	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056884	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056885	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056886	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056887	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056888	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056889	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056890	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056891	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056892	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056893	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056894	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056895	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056896	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056897	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056899	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056900	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056901	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056902	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056903	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056904	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056905	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056906	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056907	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056908	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056909	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056910	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056911	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056912	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056913	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056914	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056916	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056917	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056918	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056919	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056920	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056921	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056922	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056923	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056924	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056925	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056927	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056928	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056929	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056930	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056931	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056932	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056933	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056934	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056935	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056936	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056937	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056938	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056939	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056940	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056941	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056942	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056943	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056944	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056945	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056946	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056947	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056948	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056950	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056951	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056952	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056953	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056954	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056955	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056957	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056958	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056959	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056960	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056961	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056962	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056963	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056964	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056965	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056966	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056967	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056968	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056969	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056970	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056971	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056972	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056973	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056974	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056975	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056976	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056977	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056978	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056979	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056980	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056981	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056982	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056983	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056984	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056985	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056986	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056987	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056988	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056989	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056990	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056991	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056992	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056993	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056994	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056995	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056996	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056997	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056998	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990056999	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057000	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057001	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057002	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057003	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057004	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057005	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057006	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057007	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057008	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057009	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057010	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057011	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057012	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057013	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057014	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057015	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057016	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057017	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057018	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057019	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057020	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057021	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057022	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057023	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057024	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057025	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057026	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057027	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057028	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057029	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057030	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057031	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057032	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057033	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057034	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057035	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057036	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057037	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057038	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057040	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057041	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057042	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057043	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057044	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057045	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057046	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057047	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057048	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057049	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057050	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057051	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057052	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057053	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057054	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057055	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057056	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057057	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057058	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057059	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057060	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057061	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057062	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057063	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057064	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057065	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057066	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057067	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057068	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057069	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057070	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057071	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057073	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057074	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057075	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057076	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057077	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057078	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057079	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057080	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057081	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057082	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057083	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057084	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057085	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057086	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057087	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057088	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057089	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057090	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057091	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057092	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057093	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057094	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057095	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057096	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057097	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057098	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057099	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057100	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057101	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057102	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057103	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057104	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057105	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057106	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057107	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057108	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057109	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057110	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057111	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057112	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057113	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057114	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057115	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057116	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057117	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057118	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057119	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057120	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057121	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057122	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057123	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057124	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057125	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057126	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057127	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057128	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057129	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057130	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057131	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057132	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057133	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057134	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057135	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057136	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057137	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057138	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057139	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057140	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057141	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057142	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057143	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057144	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057145	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057146	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057147	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057148	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057149	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057150	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057151	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057152	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057153	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057154	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057155	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057156	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057157	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057158	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057159	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057160	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057161	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057162	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057163	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057164	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057165	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057166	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057167	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057168	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057169	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057170	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057171	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057172	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057173	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057174	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057175	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057176	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057177	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057178	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057179	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057180	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057181	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057182	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057183	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057184	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057185	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057186	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057187	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057188	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057189	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057190	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057191	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057192	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057193	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057194	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057195	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057196	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057197	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057198	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057199	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057200	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057201	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057202	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057203	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057204	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057205	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057206	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057207	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057208	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057209	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057210	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057211	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057212	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057213	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057214	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057215	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057216	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057217	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057218	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057219	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057220	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057221	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057222	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057223	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057224	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057225	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057226	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057227	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057228	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057229	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057230	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057231	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057232	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057233	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057234	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057235	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057236	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057237	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057238	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057239	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057240	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057241	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057242	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057243	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057244	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057245	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057246	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057247	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057248	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057249	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057250	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057251	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057252	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057253	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057254	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057255	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057256	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057257	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057258	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057259	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057260	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057261	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057262	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057263	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057264	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057265	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057266	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057267	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057268	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057269	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057270	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057271	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057272	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057273	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057274	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057275	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057276	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057277	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057278	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057279	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057280	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057281	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057282	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057283	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057284	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057285	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057286	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057287	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057288	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057289	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057290	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057291	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057292	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057293	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057294	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057295	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057296	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057297	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057298	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057299	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057300	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057301	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057302	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057303	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057304	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057305	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057306	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057307	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057308	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057309	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057310	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057311	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057312	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057313	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057314	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057315	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057316	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057317	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057318	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057319	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057320	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057321	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057322	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057323	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057324	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057325	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057326	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057327	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057328	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057329	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo	990057330	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	100790915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	100790926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	100791247	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	101164949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	101809330	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	102344360	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	102344362	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	102344364	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	102344367	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	102344369	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	102344370	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	102344373	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	102344376	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	102344379	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	102344381	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	102637795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	102785439	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	102788263	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	103593382	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	103703039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	103703072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	103943507	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	103943509	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	104308528	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	104334898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	105541340	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	105541343	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	105541501	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	105560548	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	105560549	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	105802853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	105807520	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	105810956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	105893324	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	106003404	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo1	990056789	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056790	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056791	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056792	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056793	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056794	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056796	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056797	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056798	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056799	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056801	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056802	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056803	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056804	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056805	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056806	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056807	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056808	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056809	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056810	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056811	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056812	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056813	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056815	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056816	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056817	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056818	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056819	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056820	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056821	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056822	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056823	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056824	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056825	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056827	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056828	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056829	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056830	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056831	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056832	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056833	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056834	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056835	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056837	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056838	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056839	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056840	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056841	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056842	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056844	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056845	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056846	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056847	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056848	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056849	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056850	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056851	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056854	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056855	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056856	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056857	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056859	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056860	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056861	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056862	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056863	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056864	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056865	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056866	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056867	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056868	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056869	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056870	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056871	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056872	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056874	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056875	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056876	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056877	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056878	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056879	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056881	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056882	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056883	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056884	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056885	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056886	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056888	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056889	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056890	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056891	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056892	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056893	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056894	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056895	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056896	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056897	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056899	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056900	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056901	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056902	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056903	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056904	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056905	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056906	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056907	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056908	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056909	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056910	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056911	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056912	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056913	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056914	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056916	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056917	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056918	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056919	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056920	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056921	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056922	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056923	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056924	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056925	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056927	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056928	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056929	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056930	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056931	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056932	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056933	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056934	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056935	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056936	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056937	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056938	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056939	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056940	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056941	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056942	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056943	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056944	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056945	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056946	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056947	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056948	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056950	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056951	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056952	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056953	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056954	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056955	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056957	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056958	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056959	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056960	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056961	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056962	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056963	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056964	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056965	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056966	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056967	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056968	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056969	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056970	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056971	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990056972	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990057147	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990057151	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990057155	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo1	990057161	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	100790915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	100790926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	100791247	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	101164949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	101809330	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	102344360	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	102344362	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	102344364	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	102344367	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	102344369	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	102344370	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	102344373	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	102344376	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	102344379	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	102344381	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	102637795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	102785439	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	102788263	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	103593382	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	103703039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	103703072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	103943507	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	103943509	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	104308528	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	104334898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	105541340	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	105541343	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	105541501	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	105560548	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	105560549	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	105802853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	105807520	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	105810956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	105893324	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	106003404	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo10	990056789	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056790	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056791	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056792	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056793	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056794	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056796	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056797	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056798	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056799	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056801	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056802	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056803	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056804	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056805	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056806	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056807	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056808	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056809	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056810	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056811	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056812	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056813	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056815	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056816	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056817	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056818	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056819	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056820	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056821	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056822	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056823	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056824	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056825	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056827	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056828	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056829	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056830	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056831	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056832	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056833	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056834	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056835	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056837	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056838	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056839	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056840	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056841	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056842	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056844	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056845	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056846	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056847	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056848	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056849	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056850	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056851	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056854	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056855	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056856	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056857	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056859	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056860	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056861	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056862	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056863	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056864	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056865	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056866	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056867	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056868	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056869	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056870	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056871	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056872	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056874	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056875	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056876	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056877	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056878	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056879	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056881	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056882	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056883	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056884	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056885	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056886	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056888	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056889	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056890	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056891	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056892	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056893	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056894	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056895	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056896	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056897	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056899	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056900	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056901	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056902	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056903	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056904	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056905	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056906	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056907	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056908	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056909	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056910	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056911	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056912	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056913	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056914	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056916	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056917	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056918	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056919	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056920	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056921	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056922	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056923	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056924	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056925	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056927	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056928	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056929	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056930	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056931	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056932	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056933	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056934	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056935	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056936	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056937	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056938	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056939	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056940	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056941	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056942	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056943	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056944	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056945	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056946	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056947	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056948	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056950	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056951	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056952	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056953	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056954	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056955	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056957	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056958	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056959	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056960	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056961	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056962	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056963	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056964	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056965	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056966	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056967	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056968	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056969	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056970	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056971	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990056972	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990057147	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990057151	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990057155	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo10	990057161	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	100790915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	100790926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	100791247	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	101164949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	101809330	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	102344360	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	102344362	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	102344364	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	102344367	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	102344369	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	102344370	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	102344373	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	102344376	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	102344379	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	102344381	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	102637795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	102785439	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	102788263	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	103593382	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	103703039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	103703072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	103943507	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	103943509	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	104308528	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	104334898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	105541340	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	105541343	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	105541501	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	105560546	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	105560548	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	105560549	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	105802853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	105807520	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	105810956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	105893324	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	106003404	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo11	990056789	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056790	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056791	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056792	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056793	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056794	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056796	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056797	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056798	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056799	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056800	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056801	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056802	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056803	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056804	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056805	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056806	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056807	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056808	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056809	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056810	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056811	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056812	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056813	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056814	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056815	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056816	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056817	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056818	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056819	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056820	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056821	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056822	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056823	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056824	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056825	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056826	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056827	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056828	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056829	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056830	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056831	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056832	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056833	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056834	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056835	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056836	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056837	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056838	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056839	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056840	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056841	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056842	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056843	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056844	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056845	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056846	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056847	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056848	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056849	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056850	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056851	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056852	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056854	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056855	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056856	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056857	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056858	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056859	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056860	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056861	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056862	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056863	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056864	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056865	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056866	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056867	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056868	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056869	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056870	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056871	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056872	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056873	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056874	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056875	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056876	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056877	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056878	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056879	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056880	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056881	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056882	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056883	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056884	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056885	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056886	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056888	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056889	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056890	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056891	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056892	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056893	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056894	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056895	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056896	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056897	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056899	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056900	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056901	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056902	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056903	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056904	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056905	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056906	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056907	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056908	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056909	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056910	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056911	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056912	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056913	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056914	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056916	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056917	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056918	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056919	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056920	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056921	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056922	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056923	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056924	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056925	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056927	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056928	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056929	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056930	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056931	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056932	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056933	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056934	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056935	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056936	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056937	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056938	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056939	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056940	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056941	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056942	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056943	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056944	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056945	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056946	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056947	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056948	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056950	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056951	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056952	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056953	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056954	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056955	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056957	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056958	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056959	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056960	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056961	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056962	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056963	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056964	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056965	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056966	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056967	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056968	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056969	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056970	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056971	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056972	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056973	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056974	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056975	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056976	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056977	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056978	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056979	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056980	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056981	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056982	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056983	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056984	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056985	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056986	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056987	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056988	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056989	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056990	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056991	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056992	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056993	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056994	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056995	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056996	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056997	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056998	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990056999	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057000	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057001	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057002	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057003	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057004	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057005	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057006	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057007	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057008	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057009	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057010	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057011	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057012	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057013	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057014	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057015	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057016	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057017	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057018	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057019	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057020	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057021	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057022	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057023	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057024	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057025	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057026	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057027	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057028	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057029	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057030	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057031	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057032	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057033	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057034	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057035	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057036	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057037	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057038	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057040	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057041	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057042	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057043	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057044	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057045	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057046	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057047	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057048	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057049	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057050	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057051	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057052	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057053	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057054	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057055	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057056	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057057	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057059	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057060	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057061	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057062	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057063	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057064	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057065	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057066	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057067	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057068	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057069	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057070	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057071	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057073	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057074	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057075	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057076	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057077	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057078	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057079	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057080	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057081	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057082	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057083	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057084	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057085	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057086	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057087	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057088	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057089	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057090	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057091	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057092	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057093	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057094	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057095	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057096	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057097	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057098	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057099	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057100	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057101	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057102	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057103	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057104	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057105	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057106	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057107	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057108	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057109	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057110	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057111	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057112	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057113	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057114	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057115	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057116	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057117	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057118	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057119	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057120	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057121	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057122	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057123	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057124	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057125	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057126	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057127	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057128	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057129	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057130	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057131	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057132	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057133	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057134	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057135	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057136	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057137	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057138	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057139	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057140	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057141	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057142	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057143	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057144	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057145	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057147	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057149	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057151	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057152	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057154	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057155	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057156	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057158	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057159	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057160	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo11	990057161	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo2	100790915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	100790926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	100791247	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	101164949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	101809330	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	102344360	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	102344362	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	102344364	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	102344367	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	102344369	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	102344370	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	102344373	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	102344376	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	102344379	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	102344381	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	102637795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	102785439	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	102788263	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	103593382	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	103703039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	103703072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	104308528	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	104334898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	105802853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	105807520	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	105810956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	105893324	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo2	106003404	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	102344360	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	102344362	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	102344364	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	102344367	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	102344369	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	102344370	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	102344373	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	102344376	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	102344379	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	102344381	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	103593382	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	103703039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	103703072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	104334898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	105802853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	105807520	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	105810956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	105893324	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	106003404	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo3	990056822	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo4	102344360	A	2010-05-17 09:35:00	2013-01-22 10:15:00	\N	DEMO_PHS	\N
demo4	102344370	A	2006-04-11 11:15:00	2013-01-22 10:15:00	\N	DEMO_PHS	\N
demo4	102344381	A	2008-12-02 16:36:00	2013-01-22 10:15:00	\N	DEMO_PHS	\N
demo4	103593382	A	2009-04-20 15:11:00	2013-01-22 10:15:00	\N	DEMO_PHS	\N
demo4	106003404	A	2010-06-03 07:45:00	2013-01-22 10:15:00	\N	DEMO_PHS	\N
demo5	100790915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	100790926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	100791247	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	101164949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	101809330	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	102344360	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	102344362	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	102344364	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	102344367	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	102344369	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	102344370	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	102344373	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	102344376	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	102344379	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	102344381	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	102637795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	102785439	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	102788263	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	103593382	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	103703039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	103703072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	103943507	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	103943509	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	104308528	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	104334898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	105541340	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	105541343	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	105541501	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	105560546	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	105560548	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	105560549	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	105802853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	105807520	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	105810956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	105893324	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	106003404	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo5	990056789	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056790	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056791	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056792	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056793	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056796	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056797	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056798	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056799	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056800	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056802	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056803	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056804	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056805	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056806	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056807	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056808	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056809	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056810	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056811	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056812	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056813	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056814	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056816	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056817	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056818	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056819	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056820	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056822	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056823	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056824	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056825	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056826	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056828	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056829	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056830	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056831	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056832	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056833	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056834	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056835	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056836	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056837	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056838	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056839	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056840	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056841	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056842	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056843	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056845	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056846	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056847	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056848	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056849	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056850	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056851	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056852	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056854	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056855	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056856	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056857	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056858	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056859	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056860	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056861	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056862	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056863	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056864	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056865	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056867	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056868	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056869	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056870	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056871	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056872	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056873	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056875	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056876	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056877	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056878	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056879	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056880	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056882	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056883	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056884	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056885	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056886	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056973	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056974	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056975	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056976	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056977	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056978	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056979	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056980	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056981	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056982	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056983	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056984	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056985	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056986	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056987	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056988	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056989	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056990	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056991	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056992	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056993	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056994	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056995	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056996	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056997	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056998	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990056999	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057000	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057001	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057002	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057003	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057004	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057005	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057006	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057007	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057008	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057009	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057010	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057011	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057012	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057013	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057014	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057015	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057016	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057017	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057018	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057019	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057020	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057021	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057022	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057023	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057024	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057025	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057026	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057027	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057028	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057029	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057030	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057031	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057032	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057033	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057034	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057035	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057036	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057037	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057038	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057040	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057041	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057042	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057043	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057044	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057045	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057046	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057047	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057048	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057049	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057050	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057051	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057052	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057053	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057054	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057055	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057056	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057057	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057149	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057154	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057158	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo5	990057159	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	100790915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	100790926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	100791247	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	101164949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	101809330	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	102344360	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	102344362	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	102344364	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	102344367	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	102344369	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	102344370	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	102344373	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	102344376	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	102344379	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	102344381	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	102637795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	102785439	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	102788263	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	103593382	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	103703039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	103703072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	103943507	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	103943509	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	104308528	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	104334898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	105541340	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	105541343	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	105541501	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	105560546	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	105560548	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	105560549	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	105802853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	105807520	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	105810956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	105893324	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	106003404	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo6	990056789	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056790	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056792	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056793	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056794	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056796	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056797	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056798	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056800	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056801	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056802	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056803	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056804	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056805	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056806	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056808	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056809	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056810	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056811	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056812	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056813	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056814	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056815	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056816	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056817	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056818	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056819	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056820	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056821	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056822	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056823	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056824	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056826	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056827	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056828	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056829	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056830	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056831	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056832	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056833	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056835	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056836	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056837	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056838	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056839	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056840	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056841	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056843	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056844	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056845	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056846	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056847	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056848	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056849	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056850	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056851	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056852	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056854	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056855	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056856	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056858	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056859	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056860	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056861	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056862	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056863	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056865	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056866	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056867	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056868	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056869	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056870	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056872	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056873	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056874	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056875	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056876	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056877	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056878	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056879	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056880	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056881	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056882	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056883	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056884	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990056886	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057146	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057150	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057153	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057162	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057163	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057164	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057165	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057166	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057167	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057168	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057169	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057170	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057171	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057172	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057173	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057174	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057175	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057176	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057177	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057178	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057179	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057180	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057181	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057182	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057183	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057184	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057185	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057186	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057187	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057188	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057189	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057190	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057191	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057192	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057193	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057194	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057195	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057196	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057197	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057198	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057199	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057200	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057201	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057202	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057203	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057204	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057205	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057206	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057207	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057208	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057209	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057210	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057211	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057212	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057213	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057214	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057215	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057216	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057217	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057218	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057219	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057220	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057221	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057222	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057223	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057224	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057225	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057226	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057227	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057228	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057229	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057230	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057231	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057232	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057233	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057234	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057235	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057236	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057237	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057238	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057239	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057240	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057241	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057242	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057243	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057244	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057245	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo6	990057246	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	100790915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	100790926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	100791247	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	101164949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	101809330	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	102344360	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	102344362	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	102344364	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	102344367	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	102344369	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	102344370	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	102344373	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	102344376	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	102344379	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	102344381	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	102637795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	102785439	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	102788263	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	103593382	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	103703039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	103703072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	103943507	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	103943509	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	104308528	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	104334898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	105541340	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	105541343	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	105541501	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	105560546	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	105560548	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	105560549	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	105802853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	105807520	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	105810956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	105893324	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	106003404	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo7	990056789	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056790	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056791	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056793	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056794	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056796	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056797	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056798	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056799	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056800	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056801	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056802	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056803	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056804	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056805	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056806	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056807	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056809	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056810	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056811	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056812	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056814	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056815	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056816	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056817	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056818	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056819	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056821	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056822	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056823	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056824	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056825	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056826	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056827	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056828	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056829	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056830	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056831	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056832	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056833	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056834	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056836	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056837	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056838	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056839	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056840	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056841	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056842	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056843	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056844	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056845	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056846	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056847	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056848	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056849	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056850	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056852	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056854	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056855	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056856	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056857	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056858	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056859	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056860	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056861	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056862	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056863	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056864	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056866	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056867	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056868	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056869	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056870	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056871	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056873	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056874	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056875	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056876	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056877	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056878	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056880	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056881	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056882	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056883	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056884	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056885	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990056887	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057058	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057148	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057157	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057247	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057248	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057249	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057250	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057251	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057252	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057253	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057254	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057255	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057256	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057257	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057258	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057259	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057260	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057261	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057262	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057263	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057264	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057265	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057266	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057267	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057268	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057269	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057270	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057271	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057272	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057273	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057274	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057275	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057276	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057277	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057278	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057279	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057280	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057281	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057282	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057283	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057284	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057285	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057286	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057287	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057288	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057289	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057290	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057291	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057292	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057293	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057294	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057295	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057296	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057297	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057298	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057299	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057300	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057301	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057302	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057303	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057304	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057305	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057306	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057307	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057308	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057309	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057310	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057311	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057312	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057313	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057314	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057315	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057316	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057317	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057318	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057319	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057320	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057321	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057322	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057323	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057324	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057325	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057326	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057327	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057328	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057329	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo7	990057330	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	100790915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	100790926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	100791247	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	101164949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	101809330	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	102344360	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	102344362	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	102344364	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	102344367	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	102344369	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	102344370	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	102344373	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	102344376	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	102344379	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	102344381	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	102637795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	102785439	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	102788263	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	103593382	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	103703039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	103703072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	103943507	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	103943509	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	104308528	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	104334898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	105541340	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	105541343	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	105541501	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	105560546	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	105560548	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	105560549	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	105802853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	105807520	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	105810956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	105893324	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	106003404	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo8	990056789	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056790	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056791	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056792	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056793	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056794	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056796	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056797	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056798	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056799	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056800	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056801	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056803	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056804	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056805	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056806	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056807	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056808	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056809	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056810	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056811	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056812	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056813	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056814	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056815	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056816	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056817	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056818	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056819	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056820	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056821	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056822	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056823	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056824	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056825	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056826	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056827	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056829	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056830	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056831	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056832	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056833	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056834	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056835	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056836	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056838	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056839	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056840	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056841	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056842	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056843	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056844	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056846	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056847	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056848	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056849	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056850	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056851	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056852	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056854	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056855	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056856	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056857	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056858	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056860	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056861	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056862	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056863	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056864	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056865	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056866	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056867	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056868	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056869	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056870	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056871	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056872	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056873	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056874	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056876	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056877	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056878	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056879	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056880	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056881	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056883	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056884	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056885	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990056886	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057059	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057060	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057061	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057062	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057063	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057064	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057065	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057066	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057067	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057068	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057069	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057070	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057071	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057073	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057074	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057075	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057076	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057077	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057078	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057079	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057080	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057081	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057082	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057083	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057084	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057085	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057086	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057087	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057088	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057089	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057090	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057091	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057092	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057093	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057094	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057095	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057096	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057097	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057098	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057099	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057100	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057101	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057102	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057103	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057104	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057105	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057106	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057107	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057108	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057109	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057110	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057111	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057112	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057113	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057114	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057115	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057116	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057117	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057118	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057119	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057120	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057121	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057122	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057123	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057124	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057125	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057126	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057127	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057128	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057129	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057130	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057131	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057132	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057133	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057134	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057135	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057136	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057137	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057138	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057139	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057140	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057141	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057142	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057143	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057144	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057145	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057152	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057156	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo8	990057160	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	100790915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	100790926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	100791247	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	101164949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	101809330	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	102344360	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	102344362	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	102344364	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	102344367	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	102344369	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	102344370	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	102344373	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	102344376	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	102344379	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	102344381	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	102637795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	102785439	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	102788263	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	103593382	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	103703039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	103703072	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	103943507	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	103943509	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	104308528	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	104334898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	105541340	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	105541343	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	105541501	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	105560546	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	105560548	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	105560549	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	105802853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	105807520	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	105810956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	105893324	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	106003404	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO_PHS	\N
demo9	990056789	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056790	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056791	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056792	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056793	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056794	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056795	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056796	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056797	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056798	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056799	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056800	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056801	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056802	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056803	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056804	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056805	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056806	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056807	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056808	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056809	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056810	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056811	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056812	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056813	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056814	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056815	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056816	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056817	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056818	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056819	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056820	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056821	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056822	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056823	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056824	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056825	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056826	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056827	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056828	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056829	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056830	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056831	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056832	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056833	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056834	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056835	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056836	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056837	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056838	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056839	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056840	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056841	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056842	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056843	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056844	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056845	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056846	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056847	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056848	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056849	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056850	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056851	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056852	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056853	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056854	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056855	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056856	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056857	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056858	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056859	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056860	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056861	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056862	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056863	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056864	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056865	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056866	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056867	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056868	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056869	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056870	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056871	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056872	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056873	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056874	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056875	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056876	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056877	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056878	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056879	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056880	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056881	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056882	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056883	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056884	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056885	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056886	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056888	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056889	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056890	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056891	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056892	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056893	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056894	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056895	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056896	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056897	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056898	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056899	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056900	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056901	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056902	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056903	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056904	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056905	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056906	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056907	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056908	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056909	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056910	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056911	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056912	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056913	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056914	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056915	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056916	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056917	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056918	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056919	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056920	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056921	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056922	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056923	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056924	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056925	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056926	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056927	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056928	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056929	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056930	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056931	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056932	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056933	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056934	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056935	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056936	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056937	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056938	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056939	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056940	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056941	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056942	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056943	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056944	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056945	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056946	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056947	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056948	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056949	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056950	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056951	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056952	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056953	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056954	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056955	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056956	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056957	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056958	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056959	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056960	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056961	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056962	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056963	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056964	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056965	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056966	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056967	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056968	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056969	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056970	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056971	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056972	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056973	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056974	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056975	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056976	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056977	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056978	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056979	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056980	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056981	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056982	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056983	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056984	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056985	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056986	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056987	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056988	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056989	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056990	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056991	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056992	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056993	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056994	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056995	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056996	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056997	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056998	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990056999	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057000	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057001	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057002	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057003	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057004	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057005	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057006	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057007	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057008	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057009	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057010	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057011	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057012	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057013	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057014	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057015	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057016	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057017	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057018	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057019	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057020	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057021	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057022	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057023	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057024	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057025	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057026	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057027	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057028	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057029	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057030	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057031	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057032	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057033	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057034	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057035	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057036	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057037	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057038	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057039	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057040	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057041	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057042	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057043	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057044	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057045	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057046	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057047	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057048	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057049	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057050	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057051	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057052	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057053	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057054	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057055	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057056	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057057	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057147	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057149	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057151	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057154	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057155	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057158	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057159	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
demo9	990057161	A	2013-02-01 11:40:00	2010-08-18 09:50:00	\N	DEMO	\N
\.


--
-- Data for Name: im_project_sites; Type: TABLE DATA; Schema: i2b2imdata; Owner: i2b2imdata
--

COPY i2b2imdata.im_project_sites (project_id, lcl_site, project_status, update_date, download_date, import_date, sourcesystem_cd, upload_id) FROM stdin;
demo	Hospital-1	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo	Hospital-2	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo	Hospital-3	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo	Hospital-4	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo	Hospital-5	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo	Hospital-7	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo	Hospital-8	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo	Hospital-6	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo1	Hospital-1	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo10	Hospital-1	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo10	Hospital-3	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo11	Hospital-1	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo11	Hospital-5	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo11	Hospital-6	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo2	Hospital-2	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo3	Hospital-3	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo4	Hospital-4	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo5	Hospital-5	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo6	Hospital-7	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo7	Hospital-8	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo8	Hospital-6	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo9	Hospital-1	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
demo9	Hospital-5	A	2013-02-01 11:40:00	\N	\N	DEMO	\N
\.


--
-- Data for Name: birn; Type: TABLE DATA; Schema: i2b2metadata; Owner: i2b2metadata
--

COPY i2b2metadata.birn (c_hlevel, c_fullname, c_name, c_synonym_cd, c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn, c_tablename, c_columnname, c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, m_applied_path, update_date, download_date, import_date, sourcesystem_cd, valuetype_cd, m_exclusion_cd, c_path, c_symbol) FROM stdin;
\.


--
-- Data for Name: custom_meta; Type: TABLE DATA; Schema: i2b2metadata; Owner: i2b2metadata
--

COPY i2b2metadata.custom_meta (c_hlevel, c_fullname, c_name, c_synonym_cd, c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn, c_tablename, c_columnname, c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, m_applied_path, update_date, download_date, import_date, sourcesystem_cd, valuetype_cd, m_exclusion_cd, c_path, c_symbol) FROM stdin;
\.


--
-- Data for Name: i2b2; Type: TABLE DATA; Schema: i2b2metadata; Owner: i2b2metadata
--

COPY i2b2metadata.i2b2 (c_hlevel, c_fullname, c_name, c_synonym_cd, c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn, c_tablename, c_columnname, c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, m_applied_path, update_date, download_date, import_date, sourcesystem_cd, valuetype_cd, m_exclusion_cd, c_path, c_symbol) FROM stdin;
\.


--
-- Data for Name: icd10_icd9; Type: TABLE DATA; Schema: i2b2metadata; Owner: i2b2metadata
--

COPY i2b2metadata.icd10_icd9 (c_hlevel, c_fullname, c_name, c_synonym_cd, c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn, c_tablename, c_columnname, c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, m_applied_path, update_date, download_date, import_date, sourcesystem_cd, valuetype_cd, m_exclusion_cd, c_path, c_symbol, plain_code) FROM stdin;
\.


--
-- Data for Name: ont_process_status; Type: TABLE DATA; Schema: i2b2metadata; Owner: i2b2metadata
--

COPY i2b2metadata.ont_process_status (process_id, process_type_cd, start_date, end_date, process_step_cd, process_status_cd, crc_upload_id, status_cd, message, entry_date, change_date, changedby_char) FROM stdin;
\.


--
-- Data for Name: schemes; Type: TABLE DATA; Schema: i2b2metadata; Owner: i2b2metadata
--

COPY i2b2metadata.schemes (c_key, c_name, c_description) FROM stdin;
\.


--
-- Data for Name: table_access; Type: TABLE DATA; Schema: i2b2metadata; Owner: i2b2metadata
--

COPY i2b2metadata.table_access (c_table_cd, c_table_name, c_protected_access, c_ontology_protection, c_hlevel, c_fullname, c_name, c_synonym_cd, c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn, c_dimtablename, c_columnname, c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd) FROM stdin;
\.


--
-- Data for Name: pm_approvals; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_approvals (approval_id, approval_name, approval_description, approval_activation_date, approval_expiration_date, object_cd, change_date, entry_date, changeby_char, status_cd) FROM stdin;
\.


--
-- Data for Name: pm_approvals_params; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_approvals_params (id, approval_id, param_name_cd, value, activation_date, expiration_date, datatype_cd, object_cd, change_date, entry_date, changeby_char, status_cd) FROM stdin;
\.


--
-- Data for Name: pm_cell_data; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_cell_data (cell_id, project_path, name, method_cd, url, can_override, change_date, entry_date, changeby_char, status_cd) FROM stdin;
CRC	/	Data Repository	REST	http://localhost:9090/i2b2/services/QueryToolService/	1	\N	\N	\N	A
FRC	/	File Repository 	SOAP	http://localhost:9090/i2b2/services/FRService/	1	\N	\N	\N	A
ONT	/	Ontology Cell	REST	http://localhost:9090/i2b2/services/OntologyService/	1	\N	\N	\N	A
WORK	/	Workplace Cell	REST	http://localhost:9090/i2b2/services/WorkplaceService/	1	\N	\N	\N	A
IM	/	IM Cell	REST	http://localhost:9090/i2b2/services/IMService/	1	\N	\N	\N	A
\.


--
-- Data for Name: pm_cell_params; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_cell_params (id, datatype_cd, cell_id, project_path, param_name_cd, value, can_override, change_date, entry_date, changeby_char, status_cd) FROM stdin;
\.


--
-- Data for Name: pm_global_params; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_global_params (id, datatype_cd, param_name_cd, project_path, value, can_override, change_date, entry_date, changeby_char, status_cd) FROM stdin;
\.


--
-- Data for Name: pm_hive_data; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_hive_data (domain_id, helpurl, domain_name, environment_cd, active, change_date, entry_date, changeby_char, status_cd) FROM stdin;
i2b2	http://www.i2b2.org	i2b2demo	DEVELOPMENT	1	\N	\N	\N	A
\.


--
-- Data for Name: pm_hive_params; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_hive_params (id, datatype_cd, domain_id, param_name_cd, value, change_date, entry_date, changeby_char, status_cd) FROM stdin;
\.


--
-- Data for Name: pm_project_data; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_project_data (project_id, project_name, project_wiki, project_key, project_path, project_description, change_date, entry_date, changeby_char, status_cd) FROM stdin;
Demo	AKTIN	http://www.i2b2.org	\N	/Demo	\N	\N	\N	\N	A
\.


--
-- Data for Name: pm_project_params; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_project_params (id, datatype_cd, project_id, param_name_cd, value, change_date, entry_date, changeby_char, status_cd) FROM stdin;
\.


--
-- Data for Name: pm_project_request; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_project_request (id, title, request_xml, change_date, entry_date, changeby_char, status_cd, project_id, submit_char) FROM stdin;
\.


--
-- Data for Name: pm_project_user_params; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_project_user_params (id, datatype_cd, project_id, user_id, param_name_cd, value, change_date, entry_date, changeby_char, status_cd) FROM stdin;
\.


--
-- Data for Name: pm_project_user_roles; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_project_user_roles (project_id, user_id, user_role_cd, change_date, entry_date, changeby_char, status_cd) FROM stdin;
@	i2b2	ADMIN	\N	\N	\N	A
Demo	AGG_SERVICE_ACCOUNT	USER	\N	\N	\N	A
Demo	AGG_SERVICE_ACCOUNT	MANAGER	\N	\N	\N	A
Demo	AGG_SERVICE_ACCOUNT	DATA_OBFSC	\N	\N	\N	A
Demo	AGG_SERVICE_ACCOUNT	DATA_AGG	\N	\N	\N	A
Demo	i2b2	MANAGER	\N	\N	\N	A
Demo	i2b2	USER	\N	\N	\N	A
Demo	i2b2	DATA_OBFSC	\N	\N	\N	A
Demo	demo	USER	\N	\N	\N	A
Demo	demo	DATA_DEID	\N	\N	\N	A
Demo	demo	DATA_OBFSC	\N	\N	\N	A
Demo	demo	DATA_AGG	\N	\N	\N	A
Demo	demo	DATA_LDS	\N	\N	\N	A
Demo	demo	EDITOR	\N	\N	\N	A
Demo	demo	DATA_PROT	\N	\N	\N	A
\.


--
-- Data for Name: pm_role_requirement; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_role_requirement (table_cd, column_cd, read_hivemgmt_cd, write_hivemgmt_cd, name_char, change_date, entry_date, changeby_char, status_cd) FROM stdin;
PM_HIVE_DATA	@	@	ADMIN	\N	\N	\N	\N	A
PM_HIVE_PARAMS	@	@	ADMIN	\N	\N	\N	\N	A
PM_PROJECT_DATA	@	@	MANAGER	\N	\N	\N	\N	A
PM_PROJECT_USER_ROLES	@	@	MANAGER	\N	\N	\N	\N	A
PM_USER_DATA	@	@	ADMIN	\N	\N	\N	\N	A
PM_PROJECT_PARAMS	@	@	MANAGER	\N	\N	\N	\N	A
PM_PROJECT_USER_PARAMS	@	@	MANAGER	\N	\N	\N	\N	A
PM_USER_PARAMS	@	@	ADMIN	\N	\N	\N	\N	A
PM_CELL_DATA	@	@	MANAGER	\N	\N	\N	\N	A
PM_CELL_PARAMS	@	@	MANAGER	\N	\N	\N	\N	A
PM_GLOBAL_PARAMS	@	@	ADMIN	\N	\N	\N	\N	A
\.


--
-- Data for Name: pm_user_data; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_user_data (user_id, full_name, password, email, project_path, change_date, entry_date, changeby_char, status_cd) FROM stdin;
i2b2	i2b2 Admin	9117d59a69dc49807671a51f10ab7f	\N	\N	\N	\N	\N	A
AGG_SERVICE_ACCOUNT	AGG_SERVICE_ACCOUNT	9117d59a69dc49807671a51f10ab7f	\N	\N	\N	\N	\N	A
demo	i2b2 User	9117d59a69dc49807671a51f10ab7f	\N	\N	\N	\N	\N	A
\.


--
-- Data for Name: pm_user_login; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_user_login (user_id, attempt_cd, entry_date, changeby_char, status_cd) FROM stdin;
\.


--
-- Data for Name: pm_user_params; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_user_params (id, datatype_cd, user_id, param_name_cd, value, change_date, entry_date, changeby_char, status_cd) FROM stdin;
\.


--
-- Data for Name: pm_user_session; Type: TABLE DATA; Schema: i2b2pm; Owner: i2b2pm
--

COPY i2b2pm.pm_user_session (user_id, session_id, expired_date, change_date, entry_date, changeby_char, status_cd) FROM stdin;
\.


--
-- Data for Name: workplace; Type: TABLE DATA; Schema: i2b2workdata; Owner: i2b2workdata
--

COPY i2b2workdata.workplace (c_name, c_user_id, c_group_id, c_share_id, c_index, c_parent_index, c_visualattributes, c_protected_access, c_tooltip, c_work_xml, c_work_xml_schema, c_work_xml_i2b2_type, c_entry_date, c_change_date, c_status_cd) FROM stdin;
\.


--
-- Data for Name: workplace_access; Type: TABLE DATA; Schema: i2b2workdata; Owner: i2b2workdata
--

COPY i2b2workdata.workplace_access (c_table_cd, c_table_name, c_protected_access, c_hlevel, c_name, c_user_id, c_group_id, c_share_id, c_index, c_parent_index, c_visualattributes, c_tooltip, c_entry_date, c_change_date, c_status_cd) FROM stdin;
demo	WORKPLACE	N	0	SHARED	shared	demo	Y	100	\N	CA 	SHARED	\N	\N	\N
demo	WORKPLACE	N	0	@	@	@	N	0	\N	CA 	@	\N	\N	\N
\.


--
-- Name: observation_fact_text_search_index_seq; Type: SEQUENCE SET; Schema: i2b2crcdata; Owner: i2b2crcdata
--

SELECT pg_catalog.setval('i2b2crcdata.observation_fact_text_search_index_seq', 1, false);


--
-- Name: qt_patient_enc_collection_patient_enc_coll_id_seq; Type: SEQUENCE SET; Schema: i2b2crcdata; Owner: i2b2crcdata
--

SELECT pg_catalog.setval('i2b2crcdata.qt_patient_enc_collection_patient_enc_coll_id_seq', 1, false);


--
-- Name: qt_patient_set_collection_patient_set_coll_id_seq; Type: SEQUENCE SET; Schema: i2b2crcdata; Owner: i2b2crcdata
--

SELECT pg_catalog.setval('i2b2crcdata.qt_patient_set_collection_patient_set_coll_id_seq', 1, false);


--
-- Name: qt_pdo_query_master_query_master_id_seq; Type: SEQUENCE SET; Schema: i2b2crcdata; Owner: i2b2crcdata
--

SELECT pg_catalog.setval('i2b2crcdata.qt_pdo_query_master_query_master_id_seq', 1, false);


--
-- Name: qt_query_instance_query_instance_id_seq; Type: SEQUENCE SET; Schema: i2b2crcdata; Owner: i2b2crcdata
--

SELECT pg_catalog.setval('i2b2crcdata.qt_query_instance_query_instance_id_seq', 1, false);


--
-- Name: qt_query_master_query_master_id_seq; Type: SEQUENCE SET; Schema: i2b2crcdata; Owner: i2b2crcdata
--

SELECT pg_catalog.setval('i2b2crcdata.qt_query_master_query_master_id_seq', 1, false);


--
-- Name: qt_query_result_instance_result_instance_id_seq; Type: SEQUENCE SET; Schema: i2b2crcdata; Owner: i2b2crcdata
--

SELECT pg_catalog.setval('i2b2crcdata.qt_query_result_instance_result_instance_id_seq', 1, false);


--
-- Name: qt_xml_result_xml_result_id_seq; Type: SEQUENCE SET; Schema: i2b2crcdata; Owner: i2b2crcdata
--

SELECT pg_catalog.setval('i2b2crcdata.qt_xml_result_xml_result_id_seq', 1, false);


--
-- Name: upload_status_upload_id_seq; Type: SEQUENCE SET; Schema: i2b2crcdata; Owner: i2b2crcdata
--

SELECT pg_catalog.setval('i2b2crcdata.upload_status_upload_id_seq', 1, false);


--
-- Name: ont_process_status_process_id_seq; Type: SEQUENCE SET; Schema: i2b2metadata; Owner: i2b2metadata
--

SELECT pg_catalog.setval('i2b2metadata.ont_process_status_process_id_seq', 1, false);


--
-- Name: pm_approvals_params_id_seq; Type: SEQUENCE SET; Schema: i2b2pm; Owner: i2b2pm
--

SELECT pg_catalog.setval('i2b2pm.pm_approvals_params_id_seq', 1, false);


--
-- Name: pm_cell_params_id_seq; Type: SEQUENCE SET; Schema: i2b2pm; Owner: i2b2pm
--

SELECT pg_catalog.setval('i2b2pm.pm_cell_params_id_seq', 1, false);


--
-- Name: pm_global_params_id_seq; Type: SEQUENCE SET; Schema: i2b2pm; Owner: i2b2pm
--

SELECT pg_catalog.setval('i2b2pm.pm_global_params_id_seq', 1, false);


--
-- Name: pm_hive_params_id_seq; Type: SEQUENCE SET; Schema: i2b2pm; Owner: i2b2pm
--

SELECT pg_catalog.setval('i2b2pm.pm_hive_params_id_seq', 1, false);


--
-- Name: pm_project_params_id_seq; Type: SEQUENCE SET; Schema: i2b2pm; Owner: i2b2pm
--

SELECT pg_catalog.setval('i2b2pm.pm_project_params_id_seq', 1, false);


--
-- Name: pm_project_request_id_seq; Type: SEQUENCE SET; Schema: i2b2pm; Owner: i2b2pm
--

SELECT pg_catalog.setval('i2b2pm.pm_project_request_id_seq', 1, false);


--
-- Name: pm_project_user_params_id_seq; Type: SEQUENCE SET; Schema: i2b2pm; Owner: i2b2pm
--

SELECT pg_catalog.setval('i2b2pm.pm_project_user_params_id_seq', 1, false);


--
-- Name: pm_user_params_id_seq; Type: SEQUENCE SET; Schema: i2b2pm; Owner: i2b2pm
--

SELECT pg_catalog.setval('i2b2pm.pm_user_params_id_seq', 1, false);


--
-- Name: qt_analysis_plugin analysis_plugin_pk; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_analysis_plugin
    ADD CONSTRAINT analysis_plugin_pk PRIMARY KEY (plugin_id);


--
-- Name: qt_analysis_plugin_result_type analysis_plugin_result_pk; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_analysis_plugin_result_type
    ADD CONSTRAINT analysis_plugin_result_pk PRIMARY KEY (plugin_id, result_type_id);


--
-- Name: code_lookup code_lookup_pk; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.code_lookup
    ADD CONSTRAINT code_lookup_pk PRIMARY KEY (table_cd, column_cd, code_cd);


--
-- Name: concept_dimension concept_dimension_pk; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.concept_dimension
    ADD CONSTRAINT concept_dimension_pk PRIMARY KEY (concept_path);


--
-- Name: encounter_mapping encounter_mapping_pk; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.encounter_mapping
    ADD CONSTRAINT encounter_mapping_pk PRIMARY KEY (encounter_ide, encounter_ide_source, project_id, patient_ide, patient_ide_source);


--
-- Name: modifier_dimension modifier_dimension_pk; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.modifier_dimension
    ADD CONSTRAINT modifier_dimension_pk PRIMARY KEY (modifier_path);


--
-- Name: observation_fact observation_fact_pk; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.observation_fact
    ADD CONSTRAINT observation_fact_pk PRIMARY KEY (patient_num, concept_cd, modifier_cd, start_date, encounter_num, instance_num, provider_id);


--
-- Name: patient_dimension patient_dimension_pk; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.patient_dimension
    ADD CONSTRAINT patient_dimension_pk PRIMARY KEY (patient_num);


--
-- Name: patient_mapping patient_mapping_pk; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.patient_mapping
    ADD CONSTRAINT patient_mapping_pk PRIMARY KEY (patient_ide, patient_ide_source, project_id);


--
-- Name: source_master pk_sourcemaster_sourcecd; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.source_master
    ADD CONSTRAINT pk_sourcemaster_sourcecd PRIMARY KEY (source_cd);


--
-- Name: set_type pk_st_id; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.set_type
    ADD CONSTRAINT pk_st_id PRIMARY KEY (id);


--
-- Name: set_upload_status pk_up_upstatus_idsettypeid; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.set_upload_status
    ADD CONSTRAINT pk_up_upstatus_idsettypeid PRIMARY KEY (upload_id, set_type_id);


--
-- Name: provider_dimension provider_dimension_pk; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.provider_dimension
    ADD CONSTRAINT provider_dimension_pk PRIMARY KEY (provider_path, provider_id);


--
-- Name: qt_patient_enc_collection qt_patient_enc_collection_pkey; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_patient_enc_collection
    ADD CONSTRAINT qt_patient_enc_collection_pkey PRIMARY KEY (patient_enc_coll_id);


--
-- Name: qt_patient_set_collection qt_patient_set_collection_pkey; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_patient_set_collection
    ADD CONSTRAINT qt_patient_set_collection_pkey PRIMARY KEY (patient_set_coll_id);


--
-- Name: qt_pdo_query_master qt_pdo_query_master_pkey; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_pdo_query_master
    ADD CONSTRAINT qt_pdo_query_master_pkey PRIMARY KEY (query_master_id);


--
-- Name: qt_privilege qt_privilege_pkey; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_privilege
    ADD CONSTRAINT qt_privilege_pkey PRIMARY KEY (protection_label_cd);


--
-- Name: qt_query_instance qt_query_instance_pkey; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_query_instance
    ADD CONSTRAINT qt_query_instance_pkey PRIMARY KEY (query_instance_id);


--
-- Name: qt_query_master qt_query_master_pkey; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_query_master
    ADD CONSTRAINT qt_query_master_pkey PRIMARY KEY (query_master_id);


--
-- Name: qt_query_result_instance qt_query_result_instance_pkey; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_query_result_instance
    ADD CONSTRAINT qt_query_result_instance_pkey PRIMARY KEY (result_instance_id);


--
-- Name: qt_query_result_type qt_query_result_type_pkey; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_query_result_type
    ADD CONSTRAINT qt_query_result_type_pkey PRIMARY KEY (result_type_id);


--
-- Name: qt_query_status_type qt_query_status_type_pkey; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_query_status_type
    ADD CONSTRAINT qt_query_status_type_pkey PRIMARY KEY (status_type_id);


--
-- Name: qt_xml_result qt_xml_result_pkey; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_xml_result
    ADD CONSTRAINT qt_xml_result_pkey PRIMARY KEY (xml_result_id);


--
-- Name: upload_status upload_status_pkey; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.upload_status
    ADD CONSTRAINT upload_status_pkey PRIMARY KEY (upload_id);


--
-- Name: visit_dimension visit_dimension_pk; Type: CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.visit_dimension
    ADD CONSTRAINT visit_dimension_pk PRIMARY KEY (encounter_num, patient_num);


--
-- Name: crc_analysis_job analsis_job_pk; Type: CONSTRAINT; Schema: i2b2hive; Owner: i2b2hive
--

ALTER TABLE ONLY i2b2hive.crc_analysis_job
    ADD CONSTRAINT analsis_job_pk PRIMARY KEY (job_id);


--
-- Name: crc_db_lookup crc_db_lookup_pk; Type: CONSTRAINT; Schema: i2b2hive; Owner: i2b2hive
--

ALTER TABLE ONLY i2b2hive.crc_db_lookup
    ADD CONSTRAINT crc_db_lookup_pk PRIMARY KEY (c_domain_id, c_project_path, c_owner_id);


--
-- Name: hive_cell_params hive_ce__pk; Type: CONSTRAINT; Schema: i2b2hive; Owner: i2b2hive
--

ALTER TABLE ONLY i2b2hive.hive_cell_params
    ADD CONSTRAINT hive_ce__pk PRIMARY KEY (id);


--
-- Name: im_db_lookup im_db_lookup_pk; Type: CONSTRAINT; Schema: i2b2hive; Owner: i2b2hive
--

ALTER TABLE ONLY i2b2hive.im_db_lookup
    ADD CONSTRAINT im_db_lookup_pk PRIMARY KEY (c_domain_id, c_project_path, c_owner_id);


--
-- Name: ont_db_lookup ont_db_lookup_pk; Type: CONSTRAINT; Schema: i2b2hive; Owner: i2b2hive
--

ALTER TABLE ONLY i2b2hive.ont_db_lookup
    ADD CONSTRAINT ont_db_lookup_pk PRIMARY KEY (c_domain_id, c_project_path, c_owner_id);


--
-- Name: work_db_lookup work_db_lookup_pk; Type: CONSTRAINT; Schema: i2b2hive; Owner: i2b2hive
--

ALTER TABLE ONLY i2b2hive.work_db_lookup
    ADD CONSTRAINT work_db_lookup_pk PRIMARY KEY (c_domain_id, c_project_path, c_owner_id);


--
-- Name: im_mpi_demographics im_mpi_demographics_pk; Type: CONSTRAINT; Schema: i2b2imdata; Owner: i2b2imdata
--

ALTER TABLE ONLY i2b2imdata.im_mpi_demographics
    ADD CONSTRAINT im_mpi_demographics_pk PRIMARY KEY (global_id);


--
-- Name: im_mpi_mapping im_mpi_mapping_pk; Type: CONSTRAINT; Schema: i2b2imdata; Owner: i2b2imdata
--

ALTER TABLE ONLY i2b2imdata.im_mpi_mapping
    ADD CONSTRAINT im_mpi_mapping_pk PRIMARY KEY (lcl_site, lcl_id, update_date);


--
-- Name: im_project_patients im_project_patients_pk; Type: CONSTRAINT; Schema: i2b2imdata; Owner: i2b2imdata
--

ALTER TABLE ONLY i2b2imdata.im_project_patients
    ADD CONSTRAINT im_project_patients_pk PRIMARY KEY (project_id, global_id);


--
-- Name: im_project_sites im_project_sites_pk; Type: CONSTRAINT; Schema: i2b2imdata; Owner: i2b2imdata
--

ALTER TABLE ONLY i2b2imdata.im_project_sites
    ADD CONSTRAINT im_project_sites_pk PRIMARY KEY (project_id, lcl_site);


--
-- Name: ont_process_status ont_process_status_pkey; Type: CONSTRAINT; Schema: i2b2metadata; Owner: i2b2metadata
--

ALTER TABLE ONLY i2b2metadata.ont_process_status
    ADD CONSTRAINT ont_process_status_pkey PRIMARY KEY (process_id);


--
-- Name: schemes schemes_pk; Type: CONSTRAINT; Schema: i2b2metadata; Owner: i2b2metadata
--

ALTER TABLE ONLY i2b2metadata.schemes
    ADD CONSTRAINT schemes_pk PRIMARY KEY (c_key);


--
-- Name: pm_approvals_params pm_approvals_params_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_approvals_params
    ADD CONSTRAINT pm_approvals_params_pkey PRIMARY KEY (id);


--
-- Name: pm_cell_data pm_cell_data_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_cell_data
    ADD CONSTRAINT pm_cell_data_pkey PRIMARY KEY (cell_id, project_path);


--
-- Name: pm_cell_params pm_cell_params_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_cell_params
    ADD CONSTRAINT pm_cell_params_pkey PRIMARY KEY (id);


--
-- Name: pm_global_params pm_global_params_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_global_params
    ADD CONSTRAINT pm_global_params_pkey PRIMARY KEY (id);


--
-- Name: pm_hive_data pm_hive_data_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_hive_data
    ADD CONSTRAINT pm_hive_data_pkey PRIMARY KEY (domain_id);


--
-- Name: pm_hive_params pm_hive_params_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_hive_params
    ADD CONSTRAINT pm_hive_params_pkey PRIMARY KEY (id);


--
-- Name: pm_project_data pm_project_data_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_project_data
    ADD CONSTRAINT pm_project_data_pkey PRIMARY KEY (project_id);


--
-- Name: pm_project_params pm_project_params_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_project_params
    ADD CONSTRAINT pm_project_params_pkey PRIMARY KEY (id);


--
-- Name: pm_project_request pm_project_request_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_project_request
    ADD CONSTRAINT pm_project_request_pkey PRIMARY KEY (id);


--
-- Name: pm_project_user_params pm_project_user_params_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_project_user_params
    ADD CONSTRAINT pm_project_user_params_pkey PRIMARY KEY (id);


--
-- Name: pm_project_user_roles pm_project_user_roles_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_project_user_roles
    ADD CONSTRAINT pm_project_user_roles_pkey PRIMARY KEY (project_id, user_id, user_role_cd);


--
-- Name: pm_role_requirement pm_role_requirement_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_role_requirement
    ADD CONSTRAINT pm_role_requirement_pkey PRIMARY KEY (table_cd, column_cd, read_hivemgmt_cd, write_hivemgmt_cd);


--
-- Name: pm_user_data pm_user_data_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_user_data
    ADD CONSTRAINT pm_user_data_pkey PRIMARY KEY (user_id);


--
-- Name: pm_user_params pm_user_params_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_user_params
    ADD CONSTRAINT pm_user_params_pkey PRIMARY KEY (id);


--
-- Name: pm_user_session pm_user_session_pkey; Type: CONSTRAINT; Schema: i2b2pm; Owner: i2b2pm
--

ALTER TABLE ONLY i2b2pm.pm_user_session
    ADD CONSTRAINT pm_user_session_pkey PRIMARY KEY (session_id, user_id);


--
-- Name: workplace_access workplace_access_pk; Type: CONSTRAINT; Schema: i2b2workdata; Owner: i2b2workdata
--

ALTER TABLE ONLY i2b2workdata.workplace_access
    ADD CONSTRAINT workplace_access_pk PRIMARY KEY (c_index);


--
-- Name: workplace workplace_pk; Type: CONSTRAINT; Schema: i2b2workdata; Owner: i2b2workdata
--

ALTER TABLE ONLY i2b2workdata.workplace
    ADD CONSTRAINT workplace_pk PRIMARY KEY (c_index);


--
-- Name: cd_idx_uploadid; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX cd_idx_uploadid ON i2b2crcdata.concept_dimension USING btree (upload_id);


--
-- Name: cl_idx_name_char; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX cl_idx_name_char ON i2b2crcdata.code_lookup USING btree (name_char);


--
-- Name: cl_idx_uploadid; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX cl_idx_uploadid ON i2b2crcdata.code_lookup USING btree (upload_id);


--
-- Name: em_encnum_idx; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX em_encnum_idx ON i2b2crcdata.encounter_mapping USING btree (encounter_num);


--
-- Name: em_idx_encpath; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX em_idx_encpath ON i2b2crcdata.encounter_mapping USING btree (encounter_ide, encounter_ide_source, patient_ide, patient_ide_source, encounter_num);


--
-- Name: em_idx_uploadid; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX em_idx_uploadid ON i2b2crcdata.encounter_mapping USING btree (upload_id);


--
-- Name: md_idx_uploadid; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX md_idx_uploadid ON i2b2crcdata.modifier_dimension USING btree (upload_id);


--
-- Name: of_idx_allobservation_fact; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX of_idx_allobservation_fact ON i2b2crcdata.observation_fact USING btree (patient_num, encounter_num, concept_cd, start_date, provider_id, modifier_cd, instance_num, valtype_cd, tval_char, nval_num, valueflag_cd, quantity_num, units_cd, end_date, location_cd, confidence_num);


--
-- Name: of_idx_clusteredconcept; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX of_idx_clusteredconcept ON i2b2crcdata.observation_fact USING btree (concept_cd);


--
-- Name: of_idx_encounter_patient; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX of_idx_encounter_patient ON i2b2crcdata.observation_fact USING btree (encounter_num, patient_num, instance_num);


--
-- Name: of_idx_modifier; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX of_idx_modifier ON i2b2crcdata.observation_fact USING btree (modifier_cd);


--
-- Name: of_idx_sourcesystem_cd; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX of_idx_sourcesystem_cd ON i2b2crcdata.observation_fact USING btree (sourcesystem_cd);


--
-- Name: of_idx_start_date; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX of_idx_start_date ON i2b2crcdata.observation_fact USING btree (start_date, patient_num);


--
-- Name: of_idx_uploadid; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX of_idx_uploadid ON i2b2crcdata.observation_fact USING btree (upload_id);


--
-- Name: of_text_search_unique; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE UNIQUE INDEX of_text_search_unique ON i2b2crcdata.observation_fact USING btree (text_search_index);


--
-- Name: pa_idx_uploadid; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX pa_idx_uploadid ON i2b2crcdata.patient_dimension USING btree (upload_id);


--
-- Name: pd_idx_allpatientdim; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX pd_idx_allpatientdim ON i2b2crcdata.patient_dimension USING btree (patient_num, vital_status_cd, birth_date, death_date, sex_cd, age_in_years_num, language_cd, race_cd, marital_status_cd, income_cd, religion_cd, zip_cd);


--
-- Name: pd_idx_dates; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX pd_idx_dates ON i2b2crcdata.patient_dimension USING btree (patient_num, vital_status_cd, birth_date, death_date);


--
-- Name: pd_idx_name_char; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX pd_idx_name_char ON i2b2crcdata.provider_dimension USING btree (provider_id, name_char);


--
-- Name: pd_idx_statecityzip; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX pd_idx_statecityzip ON i2b2crcdata.patient_dimension USING btree (statecityzip_path, patient_num);


--
-- Name: pd_idx_uploadid; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX pd_idx_uploadid ON i2b2crcdata.provider_dimension USING btree (upload_id);


--
-- Name: pk_archive_obsfact; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX pk_archive_obsfact ON i2b2crcdata.archive_observation_fact USING btree (encounter_num, patient_num, concept_cd, provider_id, start_date, modifier_cd, archive_upload_id);


--
-- Name: pm_encpnum_idx; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX pm_encpnum_idx ON i2b2crcdata.patient_mapping USING btree (patient_ide, patient_ide_source, patient_num);


--
-- Name: pm_idx_uploadid; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX pm_idx_uploadid ON i2b2crcdata.patient_mapping USING btree (upload_id);


--
-- Name: pm_patnum_idx; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX pm_patnum_idx ON i2b2crcdata.patient_mapping USING btree (patient_num);


--
-- Name: qt_apnamevergrp_idx; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX qt_apnamevergrp_idx ON i2b2crcdata.qt_analysis_plugin USING btree (plugin_name, version_cd, group_id);


--
-- Name: qt_idx_pqm_ugid; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX qt_idx_pqm_ugid ON i2b2crcdata.qt_pdo_query_master USING btree (user_id, group_id);


--
-- Name: qt_idx_qi_mstartid; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX qt_idx_qi_mstartid ON i2b2crcdata.qt_query_instance USING btree (query_master_id, start_date);


--
-- Name: qt_idx_qi_ugid; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX qt_idx_qi_ugid ON i2b2crcdata.qt_query_instance USING btree (user_id, group_id);


--
-- Name: qt_idx_qm_ugid; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX qt_idx_qm_ugid ON i2b2crcdata.qt_query_master USING btree (user_id, group_id, master_type_cd);


--
-- Name: qt_idx_qpsc_riid; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX qt_idx_qpsc_riid ON i2b2crcdata.qt_patient_set_collection USING btree (result_instance_id);


--
-- Name: vd_idx_allvisitdim; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX vd_idx_allvisitdim ON i2b2crcdata.visit_dimension USING btree (encounter_num, patient_num, inout_cd, location_cd, start_date, length_of_stay, end_date);


--
-- Name: vd_idx_dates; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX vd_idx_dates ON i2b2crcdata.visit_dimension USING btree (encounter_num, start_date, end_date);


--
-- Name: vd_idx_uploadid; Type: INDEX; Schema: i2b2crcdata; Owner: i2b2crcdata
--

CREATE INDEX vd_idx_uploadid ON i2b2crcdata.visit_dimension USING btree (upload_id);


--
-- Name: crc_idx_aj_qnstid; Type: INDEX; Schema: i2b2hive; Owner: i2b2hive
--

CREATE INDEX crc_idx_aj_qnstid ON i2b2hive.crc_analysis_job USING btree (queue_name, status_type_id);


--
-- Name: meta_appl_path_icd10_icd9_idx; Type: INDEX; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE INDEX meta_appl_path_icd10_icd9_idx ON i2b2metadata.icd10_icd9 USING btree (m_applied_path);


--
-- Name: meta_applied_path_idx_birn; Type: INDEX; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE INDEX meta_applied_path_idx_birn ON i2b2metadata.birn USING btree (m_applied_path);


--
-- Name: meta_applied_path_idx_custom; Type: INDEX; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE INDEX meta_applied_path_idx_custom ON i2b2metadata.custom_meta USING btree (m_applied_path);


--
-- Name: meta_applied_path_idx_i2b2; Type: INDEX; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE INDEX meta_applied_path_idx_i2b2 ON i2b2metadata.i2b2 USING btree (m_applied_path);


--
-- Name: meta_exclusion_icd10_icd9_idx; Type: INDEX; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE INDEX meta_exclusion_icd10_icd9_idx ON i2b2metadata.icd10_icd9 USING btree (m_exclusion_cd);


--
-- Name: meta_exclusion_idx_i2b2; Type: INDEX; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE INDEX meta_exclusion_idx_i2b2 ON i2b2metadata.i2b2 USING btree (m_exclusion_cd);


--
-- Name: meta_fullname_idx_birn; Type: INDEX; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE INDEX meta_fullname_idx_birn ON i2b2metadata.birn USING btree (c_fullname);


--
-- Name: meta_fullname_idx_custom; Type: INDEX; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE INDEX meta_fullname_idx_custom ON i2b2metadata.custom_meta USING btree (c_fullname);


--
-- Name: meta_fullname_idx_i2b2; Type: INDEX; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE INDEX meta_fullname_idx_i2b2 ON i2b2metadata.i2b2 USING btree (c_fullname);


--
-- Name: meta_fullname_idx_icd10_icd9; Type: INDEX; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE INDEX meta_fullname_idx_icd10_icd9 ON i2b2metadata.icd10_icd9 USING btree (c_fullname);


--
-- Name: meta_hlevel_icd10_icd9_idx; Type: INDEX; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE INDEX meta_hlevel_icd10_icd9_idx ON i2b2metadata.icd10_icd9 USING btree (c_hlevel);


--
-- Name: meta_hlevel_idx_i2b2; Type: INDEX; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE INDEX meta_hlevel_idx_i2b2 ON i2b2metadata.i2b2 USING btree (c_hlevel);


--
-- Name: meta_synonym_icd10_icd9_idx; Type: INDEX; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE INDEX meta_synonym_icd10_icd9_idx ON i2b2metadata.icd10_icd9 USING btree (c_synonym_cd);


--
-- Name: meta_synonym_idx_i2b2; Type: INDEX; Schema: i2b2metadata; Owner: i2b2metadata
--

CREATE INDEX meta_synonym_idx_i2b2 ON i2b2metadata.i2b2 USING btree (c_synonym_cd);


--
-- Name: pm_user_login_idx; Type: INDEX; Schema: i2b2pm; Owner: i2b2pm
--

CREATE INDEX pm_user_login_idx ON i2b2pm.pm_user_login USING btree (user_id, entry_date);


--
-- Name: set_upload_status fk_up_set_type_id; Type: FK CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.set_upload_status
    ADD CONSTRAINT fk_up_set_type_id FOREIGN KEY (set_type_id) REFERENCES i2b2crcdata.set_type(id);


--
-- Name: qt_patient_enc_collection qt_fk_pesc_ri; Type: FK CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_patient_enc_collection
    ADD CONSTRAINT qt_fk_pesc_ri FOREIGN KEY (result_instance_id) REFERENCES i2b2crcdata.qt_query_result_instance(result_instance_id);


--
-- Name: qt_patient_set_collection qt_fk_psc_ri; Type: FK CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_patient_set_collection
    ADD CONSTRAINT qt_fk_psc_ri FOREIGN KEY (result_instance_id) REFERENCES i2b2crcdata.qt_query_result_instance(result_instance_id);


--
-- Name: qt_query_instance qt_fk_qi_mid; Type: FK CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_query_instance
    ADD CONSTRAINT qt_fk_qi_mid FOREIGN KEY (query_master_id) REFERENCES i2b2crcdata.qt_query_master(query_master_id);


--
-- Name: qt_query_instance qt_fk_qi_stid; Type: FK CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_query_instance
    ADD CONSTRAINT qt_fk_qi_stid FOREIGN KEY (status_type_id) REFERENCES i2b2crcdata.qt_query_status_type(status_type_id);


--
-- Name: qt_query_result_instance qt_fk_qri_rid; Type: FK CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_query_result_instance
    ADD CONSTRAINT qt_fk_qri_rid FOREIGN KEY (query_instance_id) REFERENCES i2b2crcdata.qt_query_instance(query_instance_id);


--
-- Name: qt_query_result_instance qt_fk_qri_rtid; Type: FK CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_query_result_instance
    ADD CONSTRAINT qt_fk_qri_rtid FOREIGN KEY (result_type_id) REFERENCES i2b2crcdata.qt_query_result_type(result_type_id);


--
-- Name: qt_query_result_instance qt_fk_qri_stid; Type: FK CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_query_result_instance
    ADD CONSTRAINT qt_fk_qri_stid FOREIGN KEY (status_type_id) REFERENCES i2b2crcdata.qt_query_status_type(status_type_id);


--
-- Name: qt_xml_result qt_fk_xmlr_riid; Type: FK CONSTRAINT; Schema: i2b2crcdata; Owner: i2b2crcdata
--

ALTER TABLE ONLY i2b2crcdata.qt_xml_result
    ADD CONSTRAINT qt_fk_xmlr_riid FOREIGN KEY (result_instance_id) REFERENCES i2b2crcdata.qt_query_result_instance(result_instance_id);


--
-- PostgreSQL database dump complete
--

