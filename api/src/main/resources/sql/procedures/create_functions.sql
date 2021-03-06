/*
  This file contains common functions that are useful writing reports
*/

/*
How to use the fuctions
concept_from_mapping('source', 'code')
concept_name(concept_id, 'locale')
encounter_type(patient_id)
age_at_enc(person_id, encounter_id)
zlemr(patient_id)
unknown_patient(patient_id)
gender(patient_id)
person_address(patient_id)
loc_registered(patient)
provider(patient_id)
program(program_name)
relationship_type(name)
person_address_state_province(patient_id)
person_address_city_village(patient_id)
person_address_three(patient_id)
person_address_two(patient_id)
person_address_one(patient_id)

*/

/*
 get concept_id from report_mapping table
*/
#
DROP FUNCTION IF EXISTS concept_from_mapping;
#
CREATE FUNCTION concept_from_mapping(
	_source varchar(50),
    _code varchar(255)
)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE mappedConcept INT;

	SELECT concept_id INTO mappedConcept FROM report_mapping WHERE source = _source and code = _code;

    RETURN mappedConcept;

END
#

/*
get names from the concept_name table
*/
#
DROP FUNCTION IF EXISTS concept_name;
#
CREATE FUNCTION concept_name(
    _conceptID INT,
    _locale varchar(50)
)
	RETURNS VARCHAR(255)
    DETERMINISTIC

BEGIN
    DECLARE conceptName varchar(255);

	SELECT name INTO conceptName FROM concept_name WHERE voided = 0 AND concept_id = _conceptID AND locale = _locale AND concept_name_type
    = "FULLY_SPECIFIED";

    RETURN conceptName;
END
#

/*
get names from the concept_name table
*/
#
DROP FUNCTION IF EXISTS encounter_type;
#
CREATE FUNCTION encounter_type(
    _encounter_type_name varchar(255)
)
	RETURNS INT
    DETERMINISTIC

BEGIN
    DECLARE enconterType varchar(255);

	SELECT encounter_type_id INTO enconterType FROM encounter_type WHERE retired = 0 and
    name = _encounter_type_name;

    RETURN enconterType;

END
#

/*
 get patient age at encounter
*/
#
DROP FUNCTION IF EXISTS age_at_enc;
#
CREATE FUNCTION age_at_enc(
    _person_id int,
    _encounter_id int
)
	RETURNS DOUBLE
    DETERMINISTIC

BEGIN
    DECLARE ageAtEnc DOUBLE;

	select round(datediff(encounter_datetime, birthdate)/365.25,1) into ageAtENC from encounter e join person p on patient_id = person_id and e.voided = 0
	and p.voided = 0 and person_id = _person_id and encounter_id = _encounter_id and encounter_type = @encounter_type group by encounter_id;

    RETURN ageAtEnc;

END
#

/*
get patient EMR ZL
*/
#
DROP FUNCTION IF EXISTS zlemr;
#
CREATE FUNCTION zlemr(
    _patient_id int
)
	RETURNS VARCHAR(255)
    DETERMINISTIC

BEGIN
    DECLARE  zlEMR VARCHAR(255);

    SELECT pid.identifier into zlEMR from patient_identifier pid where voided = 0 and pid.identifier_type = (select pid2.patient_identifier_type_id from patient_identifier_type pid2 where
pid2.name = 'ZL EMR ID') and patient_id = _patient_id order by preferred desc limit 1;

    RETURN zlEMR;

END
#
DROP FUNCTION IF EXISTS dosId;
#

CREATE FUNCTION dosId (patient_id_in int(11))
RETURNS varchar(50)

DETERMINISTIC

BEGIN

DECLARE dosId_out varchar(50);

select identifier into dosId_out
from patient_identifier pid
where pid.patient_id = patient_id_in
and pid.voided = 0
and pid.identifier_type = 
  (select patient_identifier_type_id from patient_identifier_type where uuid = 'e66645eb-03a8-4991-b4ce-e87318e37566')
order by pid.preferred desc, pid.date_created asc limit 1   
;

RETURN dosId_out;

END;
#
/*
unknown patient
*/
#
DROP FUNCTION IF EXISTS unknown_patient;
#
CREATE FUNCTION unknown_patient(
    _patient_id int
)
	RETURNS VARCHAR(50)
    DETERMINISTIC

BEGIN
    DECLARE  unknownPatient VARCHAR(50);

	select person_id into unknownPatient from person_attribute where person_attribute_type_id = (select person_attribute_type_id from
person_attribute_type where name = 'Unknown patient') and voided = 0 and person_id = _patient_id;

    RETURN unknownPatient;

END
#

/*
gender
*/
#
DROP FUNCTION IF EXISTS gender;
#
CREATE FUNCTION gender(
    _patient_id int
)
	RETURNS VARCHAR(50)
    DETERMINISTIC

BEGIN
    DECLARE  patientGender VARCHAR(50);

	select gender into patientGender from person where person_id = _patient_id and voided =0;

    RETURN patientGender;

END
#

/*
 patient address
*/
#
DROP FUNCTION IF EXISTS person_address;
#
CREATE FUNCTION person_address(
    _patient_id int
)
	RETURNS TEXT
    DETERMINISTIC

BEGIN
    DECLARE patientAddress TEXT;

	select concat(IFNULL(state_province,''), ',' ,IFNULL(city_village,''), ',', IFNULL(address3,''), ',', IFNULL(address1,''), ',',IFNULL(address2,'')) into patientAddress
    from person_address where voided = 0 and person_id = _patient_id order by preferred desc, date_created desc limit 1;

    RETURN patientAddress;

END
#

/*
  ZL EMR ID location
*/
#
DROP FUNCTION IF EXISTS loc_registered;
#
CREATE FUNCTION loc_registered(
    _patient_id int
)
	RETURNS VARCHAR(255)
    DETERMINISTIC

BEGIN
    DECLARE locRegistered varchar(255);

select name into locRegistered from location l join patient_identifier pi on pi.location_id = l.location_id and pi.voided = 0 and pi.patient_id = _patient_id
and identifier_type = (select pid2.patient_identifier_type_id from patient_identifier_type pid2 where
 pid2.name = 'ZL EMR ID');

    RETURN locRegistered;

END
#
/*
Provider
*/
#
DROP FUNCTION IF EXISTS provider;
#
CREATE FUNCTION provider (
    _encounter_id int
) 
	RETURNS varchar(255)
    DETERMINISTIC
BEGIN
    DECLARE providerName varchar(255);

select CONCAT(given_name, ' ', family_name) into providerName
from person_name pn join provider pv on pn.person_id = pv.person_id AND pn.voided = 0 
join encounter_provider ep on pv.provider_id = ep.provider_id and ep.voided = 0 and ep.encounter_id = _encounter_id;
    
    RETURN providerName;
    
END
#
/*
Visit date
*/
#
DROP FUNCTION IF EXISTS visit_date;
#
CREATE FUNCTION visit_date(
    _patient_id int
)
	RETURNS DATE
    DETERMINISTIC

BEGIN
    DECLARE visitDate date;

    select date(date_started) into visitDate from visit where voided = 0 and visit_id = (select visit_id from encounter where encounter_type = @encounter_type)
and patient_id = _patient_id;

    RETURN visitDate;

END
#
/*
Program
*/
#
DROP FUNCTION IF EXISTS program;
#
CREATE FUNCTION program(_name varchar (255))
	RETURNS INT
    DETERMINISTIC

BEGIN
    DECLARE programId int;

    select program_id into programId from program where retired = 0 and name = _name;

    RETURN programId;

END
#
/*
Relationship
*/
#
DROP FUNCTION IF EXISTS relation_type;
#
CREATE FUNCTION relation_type(
    _name VARCHAR(255)
)
	RETURNS INT
    DETERMINISTIC

BEGIN
    DECLARE relationshipID INT;

	SELECT relationship_type_id INTO relationshipID FROM relationship_type WHERE retired = 0 AND a_is_to_b = _name;

    RETURN relationshipID;
END
#

#

/*
 patient address
*/

#
DROP FUNCTION IF EXISTS person_address_state_province;
#
CREATE FUNCTION person_address_state_province(
    _patient_id int
)
	RETURNS TEXT
    DETERMINISTIC

BEGIN
    DECLARE patientAddressStateProvince TEXT;

	select state_province into patientAddressStateProvince
    from person_address where voided = 0 and person_id = _patient_id order by preferred desc, date_created desc limit 1;

    RETURN patientAddressStateProvince;

END
#

#
DROP FUNCTION IF EXISTS person_address_city_village;
#
CREATE FUNCTION person_address_city_village(
    _patient_id int
)
	RETURNS TEXT
    DETERMINISTIC

BEGIN
    DECLARE patientAddressCityVillage TEXT;

	select city_village into patientAddressCityVillage
    from person_address where voided = 0 and person_id = _patient_id order by preferred desc, date_created desc limit 1;

    RETURN patientAddressCityVillage;

END
#

#
DROP FUNCTION IF EXISTS person_address_three;
#
CREATE FUNCTION person_address_three(
    _patient_id int
)
	RETURNS TEXT
    DETERMINISTIC

BEGIN
    DECLARE patientAddressThree TEXT;

	select address3 into patientAddressThree
    from person_address where voided = 0 and person_id = _patient_id order by preferred desc, date_created desc limit 1;

    RETURN patientAddressThree;

END
#

#
DROP FUNCTION IF EXISTS person_address_one;
#
CREATE FUNCTION person_address_one(
    _patient_id int
)
	RETURNS TEXT
    DETERMINISTIC

BEGIN
    DECLARE patientAddressOne TEXT;

	select address1 into patientAddressOne
    from person_address where voided = 0 and person_id = _patient_id order by preferred desc, date_created desc limit 1;

    RETURN patientAddressOne;

END
#

#
DROP FUNCTION IF EXISTS person_address_two;
#
CREATE FUNCTION person_address_two(
    _patient_id int
)
	RETURNS TEXT
    DETERMINISTIC

BEGIN
    DECLARE patientAddressTwo TEXT;

	select address2 into patientAddressTwo
    from person_address where voided = 0 and person_id = _patient_id order by preferred desc, date_created desc limit 1;

    RETURN patientAddressTwo;

END
#

-- This function accepts a patient_id, concept_id and beginDate
-- It will return the obs_id of the most recent observation for that patient and concept_id SINCE the beginDate
-- if null is passed in as the beginDate, it will be disregarded
-- example: select latestObs(311450, 357, '2020-01-01') or select latestObs(311450, 357, '2020-02-12 08:59:59');

#
DROP FUNCTION IF EXISTS latestObs;
#
CREATE FUNCTION latestObs (patient_id_in int(11), concept_id_in int (11), beginDate datetime)
    RETURNS int(11)
    DETERMINISTIC

BEGIN

    DECLARE obs_id_out int(11);

    select obs_id into obs_id_out
    from obs o
    where o.voided = 0
      and o.person_id = patient_id_in
      and o.concept_id = concept_id_in
      and (beginDate is null or o.obs_datetime >= beginDate)
    order by o.obs_datetime desc
    limit 1;

    RETURN obs_id_out;

END
#
