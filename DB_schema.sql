-- /*******************************************************************************
-- 
-- Proyecto Flora de Bogota
-- 
-- Jardin Botanico de Bogota
-- 
-- Esquema de base de datos MariaDB
-- 
-- 2025-03-21
-- 
-- Nelson R. Salinas
-- 
-- ********************************************************************************
-- 
-- This schema is free software: you can redistribute it and/or modify it under 
-- the terms of the GNU General Public License as published by the Free Software 
-- Foundation, either version 3 of the License, or (at your option) any later 
-- version.
-- 
-- This schema is distributed in the hope that it will be useful, but WITHOUT ANY 
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
-- PARTICULAR PURPOSE. See the GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along with 
-- this schema. If not, see <https://www.gnu.org/licenses/>. 
-- 
-- *******************************************************************************/

DROP DATABASE IF EXISTS `Mutis`;
CREATE DATABASE IF NOT EXISTS `Mutis`;

USE `Mutis`;

DROP TABLE IF EXISTS `Taxa`;
CREATE TABLE `Taxa` (
	`TaxonID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
	`Name` VARCHAR(255) NOT NULL,
	`AcceptedName` SMALLINT UNSIGNED, -- references `Taxa.TaxonID`
	`Authority` SMALLINT UNSIGNED,
	`Author` VARCHAR(100),
	`Protologue` VARCHAR(255), -- Nomenclatural publication from IPNI 
	`Parent` SMALLINT UNSIGNED, -- references `Taxa.TaxonID`
	`Comment` VARCHAR(255),
	`CheckPriority` SMALLINT UNSIGNED, -- 0 (low priority) to 5 (high priority)
	`Distribution` SMALLINT UNSIGNED, -- 0: Endémica, 1: Cundinamarca, 2: Colombia, 3: Sudamerica, 4: Americas
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `Origins`;
CREATE TABLE `Origins` (
	`OriginID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Type` TINYINT UNSIGNED, -- `Native` | `Introduced` | `Cultivated` |
	`Taxon` SMALLINT UNSIGNED,
	`Source` SMALLINT UNSIGNED,
	`Date` DATE,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `Sources`;
CREATE TABLE `Sources` (
	`SourceID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Type` ENUM ('Document', 'Person'),
	`Author` INT UNSIGNED,
	`Name` VARCHAR(750),
	`Year` SMALLINT UNSIGNED,
	`Journal` VARCHAR(255),
	`Publisher` VARCHAR(255),
	`Pages` VARCHAR(255),
	`URL` VARCHAR(255), -- DOI usually
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `Persons`;
CREATE TABLE `Persons` (
	`PersonID`  SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`NameVerbatim` VARCHAR(255),
	`FirstName` VARCHAR(255),
	`LastName` VARCHAR(255),
	`Abbreviation` VARCHAR(255),
	`Affiliation` VARCHAR(255),
	`Email` VARCHAR(255),
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `People`; -- Groups of persons, even solitary
CREATE TABLE `People` (
	`PeopleID`  INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `PeoplePersons`;
CREATE TABLE `PeoplePersons` (
	`People`  INT UNSIGNED NOT NULL,
	`Person` SMALLINT UNSIGNED NOT NULL,
	`Order` TINYINT UNSIGNED NOT NULL, -- Order of person in team
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `Identifications`;
CREATE TABLE `Identifications` (
	`IdentificationID`  INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
	`Occurrence`  INT UNSIGNED,
	`Name` SMALLINT UNSIGNED,
	`HybridSecondaryParental` SMALLINT UNSIGNED, -- If hybrid doesn't have its own name, the second parental name is included here
	`Certainty` VARCHAR(20),
	`IdentifiedByVerbatim` INT UNSIGNED, -- Sometimes id comes from a document; in that case identifier can be NULL
	`IdentifiedBy` INT UNSIGNED, -- Sometimes id comes from a document; in that case identifier can be NULL
	`Publication` SMALLINT UNSIGNED, 
	`Date` DATE,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `Occurrences`;
CREATE TABLE `Occurrences` (	
	`OccurrenceID` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`DB2015ID` INT UNSIGNED,
	`Type` TINYINT UNSIGNED , -- `Specimen` | `Observation` | `Photograph`
	`Reference` SMALLINT UNSIGNED, -- Publication in `Sources`
	`Collector` INT UNSIGNED,
	`CollectorVerbatim` VARCHAR(255),
	`CollectionNumber` SMALLINT UNSIGNED, -- Integer part of collection number
	`CollectionNumberVerbatim` VARCHAR(255),
	`Location` MEDIUMINT UNSIGNED,
	`DateInit` DATE,
	`DateEnd` DATE,
	`PhenoState` ENUM ('flor', 'fruto', 'flor y fruto', 'estéril'),
	`Use` VARCHAR(255),
	`CommonName` VARCHAR(255),
	`Comment` VARCHAR(900),
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
	-- FOREIGN KEY (`Reference`) REFERENCES Sources (`SourceID`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- -----

DROP TABLE IF EXISTS `Specimens`;
CREATE TABLE `Specimens` (
	-- Either a preserved collections or a digital evidence (photograph, audio recording)
	`SpecimenID` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Occurrence` INT UNSIGNED,
	`Institution` SMALLINT UNSIGNED,
	`SpecimenCode` VARCHAR(20), -- Collection number of the specimen in the institution, tipically a barcode number
	`File` VARCHAR(255), -- Path to file.,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- --

DROP TABLE IF EXISTS `Institutions`;
CREATE TABLE `Institutions` (
	`InstitutionID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Code` VARCHAR(10), -- e.g., herbarium code 
	`Name` VARCHAR(255),
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- --

DROP TABLE IF EXISTS `RedListAssessments`;
CREATE TABLE `RedListAssessments` (	
	`AssessmentID` MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Standard` TINYINT UNSIGNED, -- `IUCN` | `USDA` | ...
	`Taxon` SMALLINT UNSIGNED,
	`Category` TINYINT UNSIGNED,
	`Criteria` VARCHAR(255),
	`Assessor` INT UNSIGNED,
	`Publication` SMALLINT UNSIGNED,
	`Date` DATE,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ---

DROP TABLE IF EXISTS `Locations`;
CREATE TABLE `Locations` (
	`LocationID`  MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`DB2020ID` MEDIUMINT UNSIGNED,
	`Latitude` DOUBLE,  -- decimal format, in label
	`Longitude` DOUBLE, -- decimal format, in label
	`ElevationMin` DOUBLE, -- m alt
	`ElevationMax` DOUBLE, -- m alt
	`Name` VARCHAR(1000),
	`Country` VARCHAR(255),
	`Admin01` VARCHAR(255), -- departamento
	`Admin02` VARCHAR(255), -- municipio
	`Admin03` VARCHAR(255), -- vereda o corregimiento
	`Area` MEDIUMINT UNSIGNED,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- --

DROP TABLE IF EXISTS `Geocodings`;
CREATE TABLE `Geocodings` (
	`GeocodingID` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Location` MEDIUMINT UNSIGNED,
	`InterpretedLat` DOUBLE,  -- decimal format,
	`InterpretedLon` DOUBLE,  -- decimal format,
	`Uncertainty` DOUBLE, -- km
	`Datum` VARCHAR(50), -- usually 'WGS84'
	`Geocoder` INT UNSIGNED,
	`Protocol` SMALLINT UNSIGNED,
	`Date` DATE,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
	-- FOREIGN KEY (`Location`) REFERENCES Locations (`LocationID`),
	-- FOREIGN KEY (`Geocoder`) REFERENCES Persons (`PersonID`),
	-- FOREIGN KEY (`Protocol`) REFERENCES Sources (`SourceID`),
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;


-- -----

/****************************************************************
-- 
--?        IS THE TABLE `Areas` NECESSARY ?????
-- 
-- Still not sure if the table `Polygons` is really necessary,
-- polygon operations can be conducted with external rutines on 
-- shapefiles. Moreover, shapefiles are conntinually updating
-- (improved precision, adopting novel administrative boundaries, 
-- etc.) and seems more elegant to have that data as separate data
-- source 
-- 
-- ****************************************************************/

DROP TABLE IF EXISTS `Areas`;
CREATE TABLE `Areas` (
	`AreaID`  MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Name` VARCHAR(255),
	`Parent`  MEDIUMINT UNSIGNED, 
	`Shape` POLYGON,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `Observations`;
CREATE TABLE `Observations` (
	`ObservationID`  MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Trait` MEDIUMINT UNSIGNED,
	`Specimen` INT UNSIGNED,
	`Observer` INT UNSIGNED,
	`State` INT UNSIGNED,  -- Either 'State' or 'Measurement', not both. 
	`Measurement` DOUBLE,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `Traits`;
CREATE TABLE `Traits` (
	`TraitID`  MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Name` VARCHAR(50),
	`Description` VARCHAR(255),
	`Type` TINYINT UNSIGNED, -- Meristic | Continuous | Discrete
	`Protocol` SMALLINT UNSIGNED,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `TraitStates`;
CREATE TABLE `TraitStates` (
	`StateID`  INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Trait` MEDIUMINT UNSIGNED,
	`Name` VARCHAR(50),
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `Projects`;
CREATE TABLE `Projects` (
	`ProjectID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Name` VARCHAR(100),
	`Leader` SMALLINT UNSIGNED,
	`Team` INT UNSIGNED,
	`Start` DATE,
	`End` DATE,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `ProjectOccurrences`;
CREATE TABLE `ProjectOccurrences` (
	`ProjectOccurrenceID` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Occurrence` INT UNSIGNED,
	`Project` SMALLINT UNSIGNED,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `ProjectObservations`;
CREATE TABLE `ProjectObservations` (
	`ProjectObservationID` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Observation` MEDIUMINT UNSIGNED,
	`Project` SMALLINT UNSIGNED,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `ProjectSamples`;
CREATE TABLE `ProjectSamples` (
	`ProjectSampleID` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Sample` INT UNSIGNED,
	`Project` SMALLINT UNSIGNED,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `Samples`;
CREATE TABLE `Samples` (
	-- Aggregation of occurrences or observations by space and---possibly---time
	`SampleID` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Location` MEDIUMINT UNSIGNED,
	`Date` DATE,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

-- ------

DROP TABLE IF EXISTS `SampleOccurrences`;
CREATE TABLE `SampleOccurrences` (
	`SampleOccID` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`Sample` INT UNSIGNED,
	`Occurrence` INT UNSIGNED,
	`TimeStamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;


ALTER TABLE `Taxa` 
	ADD CONSTRAINT `taxa_authority_foreign` 
	FOREIGN KEY(`Authority`)
	REFERENCES `Sources`(`SourceID`);

ALTER TABLE `Origins` 
	ADD CONSTRAINT `origins_taxon_foreign` 
	FOREIGN KEY(`Taxon`) 
	REFERENCES `Taxa`(`TaxonID`);

ALTER TABLE `Origins` 
	ADD CONSTRAINT `origins_source_foreign` 
	FOREIGN KEY(`Source`) 
	REFERENCES `Sources`(`SourceID`);


ALTER TABLE `Sources` 
	ADD CONSTRAINT `sources_author_foreign` 
	FOREIGN KEY(`Author`) 
	REFERENCES `People`(`PeopleID`);

ALTER TABLE `PeoplePersons` 
	ADD CONSTRAINT `peoplepersons_people_foreign` 
	FOREIGN KEY (`People`) 
	REFERENCES `People` (`PeopleID`);

ALTER TABLE `PeoplePersons` 
	ADD CONSTRAINT `peoplepersons_person_foreign` 
	FOREIGN KEY (`Person`) 
	REFERENCES `Persons` (`PersonID`);


ALTER TABLE `Identifications` 
	ADD CONSTRAINT `identifications_nameid_foreign` 
	FOREIGN KEY (`Name`) 
	REFERENCES `Taxa` (`TaxonID`);

ALTER TABLE `Identifications` 
	ADD CONSTRAINT `identifications_hibrid2_foreign` 
	FOREIGN KEY (`HybridSecondaryParental`) 
	REFERENCES `Taxa` (`TaxonID`);


ALTER TABLE `Identifications` 
	ADD CONSTRAINT `identifications_occurrence_foreign` 
	FOREIGN KEY (`Occurrence`) 
	REFERENCES `Occurrences` (`OccurrenceID`);

ALTER TABLE `Identifications` 
	ADD CONSTRAINT `identifications_identifiedby_foreign` 
	FOREIGN KEY (`IdentifiedBy`) 
	REFERENCES `People` (`PeopleID`); -- Should this be people groups?

ALTER TABLE `Identifications` 
	ADD CONSTRAINT `identifications_publication_foreign` 
	FOREIGN KEY (`Publication`) 
	REFERENCES `Sources`(`SourceID`);

ALTER TABLE `Occurrences` 
	ADD CONSTRAINT `occurrences_collector_foreign` 
	FOREIGN KEY (`Collector`) 
	REFERENCES `People` (`PeopleID`);

ALTER TABLE `Occurrences` 
	ADD CONSTRAINT `occurrences_location_foreign` 
	FOREIGN KEY (`Location`) 
	REFERENCES `Locations` (`LocationID`);

ALTER TABLE `Specimens` 
	ADD CONSTRAINT `specimens_occurrence_foreign` 
	FOREIGN KEY (`Occurrence`) 
	REFERENCES `Occurrences` (`OccurrenceID`);

ALTER TABLE `Specimens` 
	ADD CONSTRAINT `specimens_institution_foreign` 
	FOREIGN KEY (`Institution`) 
	REFERENCES `Institutions` (`InstitutionID`);

ALTER TABLE `RedListAssessments` 
	ADD CONSTRAINT `redlistassessments_taxon_foreign` 
	FOREIGN KEY (`Taxon`) 
	REFERENCES `Taxa` (`TaxonID`);

ALTER TABLE `RedListAssessments` 
	ADD CONSTRAINT `redlistassessments_assessor_foreign` 
	FOREIGN KEY (`Assessor`) 
	REFERENCES `People` (`PeopleID`);

ALTER TABLE `RedListAssessments` 
	ADD CONSTRAINT `redlistassessments_publication_foreign` 
	FOREIGN KEY (`Publication`) 
	REFERENCES `Sources` (`SourceID`);

ALTER TABLE `Locations` 
	ADD CONSTRAINT `locations_area_foreign` 
	FOREIGN KEY(`Area`) 
	REFERENCES `Areas`(`AreaID`);

ALTER TABLE `Geocodings` 
	ADD CONSTRAINT `geocodings_location_foreign` 
	FOREIGN KEY (`Location`) 
	REFERENCES `Locations` (`LocationID`);

ALTER TABLE `Geocodings` 
	ADD CONSTRAINT `geocodings_geocoder_foreign` 
	FOREIGN KEY (`Geocoder`) 
	REFERENCES `People` (`PeopleID`);

ALTER TABLE `Geocodings` 
	ADD CONSTRAINT `geocodings_protocol_foreign` 
	FOREIGN KEY (`Protocol`) 
	REFERENCES `Sources` (`SourceID`);

ALTER TABLE `Areas`
	ADD CONSTRAINT `areas_parent_foreign`
	FOREIGN KEY (`Parent`)
	REFERENCES `Areas` (`AreaID`);

ALTER TABLE `Observations` 
	ADD CONSTRAINT `observations_observer_foreign` 
	FOREIGN KEY (`Observer`) 
	REFERENCES `People` (`PeopleID`);

ALTER TABLE `Observations` 
	ADD CONSTRAINT `observations_specimen_foreign` 
	FOREIGN KEY (`Specimen`) 
	REFERENCES `Specimens` (`SpecimenID`);

ALTER TABLE `Observations` 
	ADD CONSTRAINT `observations_trait_foreign` 
	FOREIGN KEY (`Trait`) 
	REFERENCES `Traits` (`TraitID`);

ALTER TABLE `Observations` 
	ADD CONSTRAINT `observations_state_foreign` 
	FOREIGN KEY (`State`) 
	REFERENCES `TraitStates` (`StateID`);

ALTER TABLE `Traits` 
	ADD CONSTRAINT `traits_protocol_foreign` 
	FOREIGN KEY (`Protocol`) 
	REFERENCES `Sources` (`SourceID`);

ALTER TABLE `TraitStates` 
	ADD CONSTRAINT `traitstates_trait_foreign` 
	FOREIGN KEY (`Trait`) 
	REFERENCES `Traits` (`TraitID`);

ALTER TABLE `Projects` 
	ADD CONSTRAINT `projects_leader_foreign` 
	FOREIGN KEY (`Leader`) 
	REFERENCES `Persons`(`PersonID`);

ALTER TABLE `Projects` 
	ADD CONSTRAINT `projects_team_foreign` 
	FOREIGN KEY (`Team`) 
	REFERENCES `People`(`PeopleID`);

ALTER TABLE `ProjectOccurrences` 
	ADD CONSTRAINT `projectsoccur_occurr_foreign` 
	FOREIGN KEY (`Occurrence`) 
	REFERENCES `Occurrences`(`OccurrenceID`);

ALTER TABLE `ProjectOccurrences` 
	ADD CONSTRAINT `projectsoccur_project_foreign` 
	FOREIGN KEY (`Project`) 
	REFERENCES `Projects`(`ProjectID`);

ALTER TABLE `ProjectObservations` 
	ADD CONSTRAINT `projectobs_obs_foreign` 
	FOREIGN KEY (`Observation`) 
	REFERENCES `Observations`(`ObservationID`);

ALTER TABLE `ProjectObservations` 
	ADD CONSTRAINT `projectobs_project_foreign` 
	FOREIGN KEY (`Project`) 
	REFERENCES `Projects`(`ProjectID`);

ALTER TABLE `ProjectSamples` 
	ADD CONSTRAINT `projectsam_project_foreign` 
	FOREIGN KEY (`Project`) 
	REFERENCES `Projects`(`ProjectID`);

ALTER TABLE `ProjectSamples` 
	ADD CONSTRAINT `projectsam_sample_foreign` 
	FOREIGN KEY (`Sample`) 
	REFERENCES `Samples`(`SampleID`);

ALTER TABLE `Samples` 
	ADD CONSTRAINT `samples_location_foreign` 
	FOREIGN KEY (`Location`) 
	REFERENCES `Locations`(`LocationID`);

ALTER TABLE `SampleOccurrences` 
	ADD CONSTRAINT `sampleocc_sample_foreign` 
	FOREIGN KEY (`Sample`) 
	REFERENCES `Samples`(`SampleID`);

ALTER TABLE `SampleOccurrences` 
	ADD CONSTRAINT `sampleocc_occur_foreign` 
	FOREIGN KEY (`Occurrence`) 
	REFERENCES `Occurrences`(`OccurrenceID`);
