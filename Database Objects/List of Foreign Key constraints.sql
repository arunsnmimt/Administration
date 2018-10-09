SELECT f.name AS ForeignKey,
OBJECT_NAME(f.parent_object_id) AS TableName,
COL_NAME(fc.parent_object_id,
fc.parent_column_id) AS ColumnName,
OBJECT_NAME (f.referenced_object_id) AS ReferenceTableName,
COL_NAME(fc.referenced_object_id,
fc.referenced_column_id) AS ReferenceColumnName
FROM sys.foreign_keys AS f
INNER JOIN sys.foreign_key_columns AS fc
ON f.OBJECT_ID = fc.constraint_object_id



SELECT DISTINCT 'ALTER TABLE ' + OBJECT_NAME(f.parent_object_id) +' DROP CONSTRAINT ' + f.name 
FROM sys.foreign_keys AS f
INNER JOIN sys.foreign_key_columns AS fc
ON f.OBJECT_ID = fc.constraint_object_id

/*
SELECT COUNT(*) FROM AAV_SOC1990
SELECT COUNT(*) FROM AAV_SOC2000
SELECT COUNT(*) FROM ACADEMIC_YEARS
SELECT COUNT(*) FROM ACL_ANNUAL_VAL_STATUSES
SELECT COUNT(*) FROM ACL_ANNUAL_VALUES  -- 47257
SELECT COUNT(*) FROM AGE_GROUPS
SELECT COUNT(*) FROM ALL_ANNUAL_VALUES  --93449

DELETE FROM ALL_ANNUAL_VALUES
WHERE ACADEMIC_YEAR_CODE IN ('0809','0910')

SELECT COUNT(*) FROM APPRENTICESHIP_TYPES
SELECT COUNT(*) FROM AREAS_OF_LEARNING
SELECT COUNT(*) FROM AWARDING_BODIES
SELECT COUNT(*) FROM COMMON_COMPONENTS
SELECT COUNT(*) FROM CURRENT_PROVISION_CODES
SELECT COUNT(*) FROM DATA_ENTRY_STATUSES
SELECT COUNT(*) FROM ENG_SCHEDULE2
SELECT COUNT(*) FROM ENGLAND_FE_HE_STATUSES
SELECT COUNT(*) FROM ENGLAND_PRESCRIBED_IDS
SELECT COUNT(*) FROM ENGLAND_PROGRAM_AREAS
SELECT COUNT(*) FROM ENGLAND_SUB_PROG_AREAS
SELECT COUNT(*) FROM ENTRY_SUB_LEVELS
SELECT COUNT(*) FROM FE_ANNUAL_VALUE_STATUSES
SELECT COUNT(*) FROM FE_ANNUAL_VALUES
SELECT COUNT(*) FROM FFA_TYPES
SELECT COUNT(*) FROM FINAL_ANNUAL_VALUES
SELECT COUNT(*) FROM FLAG_DESCRIPTIONS
SELECT COUNT(*) FROM FRAMEWORK_AIMS
SELECT COUNT(*) FROM FRAMEWORK_CMN_COMPONENTS
SELECT COUNT(*) FROM FRAMEWORK_COMPONENT_TYPES
SELECT COUNT(*) FROM FRAMEWORK_MAND_KEY_SKILLS
SELECT COUNT(*) FROM FRAMEWORK_TYPES
SELECT COUNT(*) FROM FRAMEWORKS
SELECT COUNT(*) FROM FUNDING_CATEGORIES
SELECT COUNT(*) FROM KEY_SKILLS
SELECT COUNT(*) FROM LAD_CURRENT_VERSION
SELECT COUNT(*) FROM LAD_VERSIONS
SELECT COUNT(*) FROM LDCS_CODES
SELECT COUNT(*) FROM LEARNING_AIM
SELECT COUNT(*) FROM LEARNING_AIM_TYPES
SELECT COUNT(*) FROM LEARNING_AIM_V2_SUBTYPES
SELECT COUNT(*) FROM LEARNING_AIM_V2_TYPES
SELECT COUNT(*) FROM LEARNING_AIM_XREFS
SELECT COUNT(*) FROM LEARNING_PROG_CODES
SELECT COUNT(*) FROM LEVEL2_ENTITLEMENT_CATS
SELECT COUNT(*) FROM LEVEL3_ENTITLEMENT_CATS

SELECT COUNT(*) FROM LINES_OF_LEARNING
SELECT COUNT(*) FROM LSC_1618_LEARNER_AVS
SELECT COUNT(*) FROM LSC_ADULT_LEARNER_AVS
SELECT COUNT(*) FROM LSC_AIM_APPROVED_BY
*/
SELECT COUNT(*) FROM LSC_ANNUAL_VALUE_STATUSES
SELECT COUNT(*) FROM LSC_EMP_RESP_WGT_FACTORS
/*
SELECT COUNT(*) FROM LSC_EMPLOYER_ANNUAL_VALUES
SELECT COUNT(*) FROM LSC_FRAMEWORK_AV_STATUSES
SELECT COUNT(*) FROM LSC_FRAMEWORK_AVS
SELECT COUNT(*) FROM LSC_FUNDING_STATUS
SELECT COUNT(*) FROM LSC_GROWTH_PRIORITIES
SELECT COUNT(*) FROM LSC_LEARN_RESP_WGT_FACTORS
SELECT COUNT(*) FROM LSC_SECTOR_SKILLS_PRI
SELECT COUNT(*) FROM MA_TYPES
SELECT COUNT(*) FROM NON_LSC_FUNDED_STATUSES
SELECT COUNT(*) FROM NOTIONAL_LEVELS_V2
SELECT COUNT(*) FROM NOTIONAL_NVQ_LEVELS
SELECT COUNT(*) FROM NVQ_DELIVERY_PERIODS
SELECT COUNT(*) FROM PROGRAMME_WGT_FACTORS
SELECT COUNT(*) FROM QCA_PATHWAYS
SELECT COUNT(*) FROM QCA_STATUSES
SELECT COUNT(*) FROM RECOMMENDED_INDICATORS
SELECT COUNT(*) FROM SECTOR_FRAMEWORK_AIMS
SELECT COUNT(*) FROM SECTOR_FRAMEWORKS
SELECT COUNT(*) FROM SECTOR_LEAD_BODIES
SELECT COUNT(*) FROM SKILLS_FOR_LIFE_TYPES
SELECT COUNT(*) FROM SOC1990_CODES
SELECT COUNT(*) FROM SOC2000_CODES
SELECT COUNT(*) FROM SSA_TIER1_CODES
SELECT COUNT(*) FROM SSA_TIER2_CODES
SELECT COUNT(*) FROM SUPERCLASSES
SELECT COUNT(*) FROM TTG_ANNUAL_VAL_STATUSES
SELECT COUNT(*) FROM TTG_ANNUAL_VALUES
SELECT COUNT(*) FROM TTG_WGT_FACTORS
SELECT COUNT(*) FROM URL_LINK_TYPES
SELECT COUNT(*) FROM VOC_RELATED
SELECT COUNT(*) FROM WBL_ANNUAL_VAL_STATUSES
SELECT COUNT(*) FROM WBL_ANNUAL_VALUES
*/

ALTER TABLE AAV_SOC1990 DROP CONSTRAINT AAV_SOC1990$Rel35
ALTER TABLE AAV_SOC1990 DROP CONSTRAINT AAV_SOC1990$Rel35
ALTER TABLE AAV_SOC1990 DROP CONSTRAINT AAV_SOC1990$Rel51
ALTER TABLE AAV_SOC1990 DROP CONSTRAINT AAV_SOC1990$Rel53
ALTER TABLE AAV_SOC2000 DROP CONSTRAINT AAV_SOC2000$Rel36
ALTER TABLE AAV_SOC2000 DROP CONSTRAINT AAV_SOC2000$Rel52
ALTER TABLE AAV_SOC2000 DROP CONSTRAINT AAV_SOC2000$Rel54
ALTER TABLE ACL_ANNUAL_VALUES DROP CONSTRAINT ACL_ANNUAL_VALUES$Rel38
ALTER TABLE ACL_ANNUAL_VALUES DROP CONSTRAINT ACL_ANNUAL_VALUES$Rel41
ALTER TABLE ACL_ANNUAL_VALUES DROP CONSTRAINT ACL_ANNUAL_VALUES$Rel42
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel18
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel19
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel2
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel20
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel21
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel22
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel23
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel24
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel25
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel40
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel47
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel48
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel49
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel50
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel55
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel56
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel57
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel58
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel59
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel74
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel87
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel95
ALTER TABLE ALL_ANNUAL_VALUES DROP CONSTRAINT ALL_ANNUAL_VALUES$Rel98
ALTER TABLE FE_ANNUAL_VALUES DROP CONSTRAINT FE_ANNUAL_VALUES$Rel29
ALTER TABLE FE_ANNUAL_VALUES DROP CONSTRAINT FE_ANNUAL_VALUES$Rel30
ALTER TABLE FE_ANNUAL_VALUES DROP CONSTRAINT FE_ANNUAL_VALUES$Rel31
ALTER TABLE FE_ANNUAL_VALUES DROP CONSTRAINT FE_ANNUAL_VALUES$Rel32
ALTER TABLE FE_ANNUAL_VALUES DROP CONSTRAINT FE_ANNUAL_VALUES$Rel33
ALTER TABLE FE_ANNUAL_VALUES DROP CONSTRAINT FE_ANNUAL_VALUES$Rel8
ALTER TABLE FINAL_ANNUAL_VALUES DROP CONSTRAINT FINAL_ANNUAL_VALUES$Rel61
ALTER TABLE FINAL_ANNUAL_VALUES DROP CONSTRAINT FINAL_ANNUAL_VALUES$Rel62
ALTER TABLE FINAL_ANNUAL_VALUES DROP CONSTRAINT FINAL_ANNUAL_VALUES$Rel63
ALTER TABLE FINAL_ANNUAL_VALUES DROP CONSTRAINT FINAL_ANNUAL_VALUES$Rel64
ALTER TABLE FINAL_ANNUAL_VALUES DROP CONSTRAINT FINAL_ANNUAL_VALUES$Rel65
ALTER TABLE FINAL_ANNUAL_VALUES DROP CONSTRAINT FINAL_ANNUAL_VALUES$Rel66
ALTER TABLE FINAL_ANNUAL_VALUES DROP CONSTRAINT FINAL_ANNUAL_VALUES$Rel75
ALTER TABLE FRAMEWORK_AIMS DROP CONSTRAINT FRAMEWORK_AIMS$Rel84
ALTER TABLE FRAMEWORK_CMN_COMPONENTS DROP CONSTRAINT FRAMEWORK_CMN_COMPONENTS$Rel80
ALTER TABLE FRAMEWORK_MAND_KEY_SKILLS DROP CONSTRAINT FRAMEWORK_MAND_KEY_SKILLS$Rel67
ALTER TABLE FRAMEWORK_MAND_KEY_SKILLS DROP CONSTRAINT FRAMEWORK_MAND_KEY_SKILLS$Rel68
ALTER TABLE FRAMEWORK_MAND_KEY_SKILLS DROP CONSTRAINT FRAMEWORK_MAND_KEY_SKILLS$Rel69
ALTER TABLE FRAMEWORKS DROP CONSTRAINT FRAMEWORKS$Rel85
ALTER TABLE FRAMEWORKS DROP CONSTRAINT FRAMEWORKS$Rel99
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel1
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel10
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel11
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel12
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel13
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel14
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel15
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel16
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel17
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel3
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel37
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel4
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel44
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel60
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel7
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel81
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel82
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel83
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel86
ALTER TABLE LEARNING_AIM DROP CONSTRAINT LEARNING_AIM$Rel9
ALTER TABLE LEARNING_AIM_XREFS DROP CONSTRAINT LEARNING_AIM_XREFS$Rel39
ALTER TABLE LEARNING_AIM_XREFS DROP CONSTRAINT LEARNING_AIM_XREFS$Rel43
ALTER TABLE LSC_1618_LEARNER_AVS DROP CONSTRAINT LSC_1618_LEARNER_AVS$Rel77
ALTER TABLE LSC_1618_LEARNER_AVS DROP CONSTRAINT LSC_1618_LEARNER_AVS$Rel89
ALTER TABLE LSC_1618_LEARNER_AVS DROP CONSTRAINT LSC_1618_LEARNER_AVS$Rel96
ALTER TABLE LSC_ADULT_LEARNER_AVS DROP CONSTRAINT LSC_ADULT_LEARNER_AVS$Rel78
ALTER TABLE LSC_ADULT_LEARNER_AVS DROP CONSTRAINT LSC_ADULT_LEARNER_AVS$Rel90
ALTER TABLE LSC_ADULT_LEARNER_AVS DROP CONSTRAINT LSC_ADULT_LEARNER_AVS$Rel97
ALTER TABLE LSC_EMPLOYER_ANNUAL_VALUES DROP CONSTRAINT LSC_EMPLOYER_ANNUAL_VALUES$Rel79
ALTER TABLE LSC_EMPLOYER_ANNUAL_VALUES DROP CONSTRAINT LSC_EMPLOYER_ANNUAL_VALUES$Rel91
ALTER TABLE LSC_EMPLOYER_ANNUAL_VALUES DROP CONSTRAINT LSC_EMPLOYER_ANNUAL_VALUES$Rel92
ALTER TABLE LSC_EMPLOYER_ANNUAL_VALUES DROP CONSTRAINT LSC_EMPLOYER_ANNUAL_VALUES$Rel93
ALTER TABLE LSC_FRAMEWORK_AVS DROP CONSTRAINT LSC_FRAMEWORK_AVS$Rel76
ALTER TABLE LSC_FRAMEWORK_AVS DROP CONSTRAINT LSC_FRAMEWORK_AVS$Rel88
ALTER TABLE LSC_FRAMEWORK_AVS DROP CONSTRAINT LSC_FRAMEWORK_AVS$Rel94
ALTER TABLE SECTOR_FRAMEWORK_AIMS DROP CONSTRAINT SECTOR_FRAMEWORK_AIMS$Rel34
ALTER TABLE SECTOR_FRAMEWORK_AIMS DROP CONSTRAINT SECTOR_FRAMEWORK_AIMS$Rel45
ALTER TABLE SECTOR_FRAMEWORK_AIMS DROP CONSTRAINT SECTOR_FRAMEWORK_AIMS$Rel46
ALTER TABLE SECTOR_FRAMEWORK_AIMS DROP CONSTRAINT SECTOR_FRAMEWORK_AIMS$Rel5
ALTER TABLE TTG_ANNUAL_VALUES DROP CONSTRAINT TTG_ANNUAL_VALUES$Rel70
ALTER TABLE TTG_ANNUAL_VALUES DROP CONSTRAINT TTG_ANNUAL_VALUES$Rel71
ALTER TABLE TTG_ANNUAL_VALUES DROP CONSTRAINT TTG_ANNUAL_VALUES$Rel72
ALTER TABLE TTG_ANNUAL_VALUES DROP CONSTRAINT TTG_ANNUAL_VALUES$Rel73
ALTER TABLE WBL_ANNUAL_VALUES DROP CONSTRAINT WBL_ANNUAL_VALUES$Rel26
ALTER TABLE WBL_ANNUAL_VALUES DROP CONSTRAINT WBL_ANNUAL_VALUES$Rel27
ALTER TABLE WBL_ANNUAL_VALUES DROP CONSTRAINT WBL_ANNUAL_VALUES$Rel28
ALTER TABLE WBL_ANNUAL_VALUES DROP CONSTRAINT WBL_ANNUAL_VALUES$Rel6

/****/
ALTER TABLE LEARNING_AIM DROP CONSTRAINT SSMA_CC$LEARNING_AIM$QCA_GLH$disallow_zero_length

