USE master

IF EXISTS (Select * from sysdatabases where name = 'RV_HillAirForceBase')
DROP DATABASE RV_HillAirForceBase

GO

CREATE DATABASE RV_HillAirForceBase

ON PRIMARY

(
NAME = 'RV_HillAirForceBase',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\RV_HillAirForceBase.mdf', --Change to your own directory
--FILENAME LOCAL
SIZE = 12MB,
MAXSIZE = 50MB,
FILEGROWTH = 10%
)

LOG ON

(
NAME = 'RV_HillAirForceBase_Log',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\RV_HillAirForceBase.ldf', --Change to your own directory
--FILENAME LOCAL
SIZE = 12MB,
MAXSIZE = 50MB,
FILEGROWTH = 10%
)

GO



--Create Tables
--------------------------------------------------------------------------------------------------------------------------

USE RV_HillAirForceBase

CREATE TABLE CUSTOMER(
	CustID					int	IDENTITY(1,1)		NOT NULL,
	CustFirstName			varchar(50)				NOT NULL,
	CustLastName			varchar(50)				NOT NULL,
	CustEmail				varchar(320)			NOT NULL,
	CustPhone				varchar(15)				NOT NULL,
	CustLastModifiedBy		varchar(10)					NULL,
	CustLastModifiedDate	smalldatetime				NULL,
	ServiceStatusID			int						NOT NULL,
	DODAffiliationID		int						NOT NULL,
	CONSTRAINT PK_CustID
	PRIMARY KEY (CustID)
)

CREATE TABLE CUSTOMER_PASSWORD(
	CustPassID				int IDENTITY(1,1)		NOT NULL,
	CustID					int						NOT NULL,
	Password				varchar(40)				NOT NULL,
	Active					bit						NOT NULL,
	PasswordAssignedDate	smalldatetime			NOT NULL,
	CONSTRAINT PK_CustPassID
	PRIMARY KEY (CustPassID),
	CONSTRAINT FK_CustID
	FOREIGN KEY (CustID) REFERENCES CUSTOMER (CustID) 
)

CREATE TABLE DOD_AFFILIATION_TYPE(
	DODAffiliationID		int	IDENTITY(1,1)	NOT NULL,
	DODAffilationType		varchar(50)			NOT NULL,
	CONSTRAINT PK_DODAffiliationID
	PRIMARY KEY (DODAffiliationID)
)

CREATE TABLE LOCATION(
	LocationID				int	IDENTITY(1,1)	NOT NULL,
	LocationName			varchar(100)		NOT NULL,
	LocationAddress1		varchar(150)		NOT NULL,
	LocationAddress2		varchar(150)			NULL,
	LocationCity			varchar(50)			NOT NULL,
	LocationState			varchar(20)			NOT NULL,
	LocationZip				varchar(10)			NOT NULL,
	CONSTRAINT PK_LocationID
	PRIMARY KEY (LocationID)
)

CREATE TABLE PAYMENT(
	PayID					int IDENTITY(1,1)	NOT NULL,
	PayDate					smalldatetime  		NOT NULL,
	PayTotalCost			smallmoney			NOT NULL,
	IsPaid					bit					NOT NULL,
	CCReference				varchar(20)				NULL,
	PayLastModifiedBy		varchar(10)				NULL,
	PayLastModifiedDate		smalldatetime			NULL,
	ResID					int					NOT NULL,
	ReasonID				int					NOT NULL,
	PayTypeID				tinyint				NOT NULL,
	CONSTRAINT PK_PayID
	PRIMARY KEY (PayID)
)

CREATE TABLE PAYMENT_REASON(
	PayReasonID				int	IDENTITY(1,1)	NOT NULL,
	PayReasonName			varchar(20)			NOT NULL,
	CONSTRAINT PK_PayReasonID
	PRIMARY KEY (PayReasonID)
)

CREATE TABLE PAYMENT_TYPE(
	PayTypeID				tinyint	IDENTITY(1,1)	NOT NULL,
	PayType					varchar(11)				NOT NULL,
	CONSTRAINT PK_PayTypeID
	PRIMARY KEY (PayTypeID)
)

CREATE TABLE RESERVATION(
	ResID					int	IDENTITY(1,1)	NOT NULL,
	ResNumAdults			tinyint				NOT NULL,
	ResNumChildren			tinyint				NOT NULL,
	ResNumPets				tinyint				NOT NULL,
	ResAcknowledgeValidPets	bit						NULL,
	ResStartDate			smalldatetime		NOT NULL,
	ResEndDate				smalldatetime		NOT NULL,
	ResCreatedDate			smalldatetime		NOT NULL,
	ResComment				varchar(max)			NULL,
	ResVehicleLength		tinyint					NULL,
	ResLastModifiedBy		varchar(10)				NULL,
	ResLastModifiedDate		smalldatetime			NULL,
	VehicleTypeID			tinyint				NOT	NULL,
	CustID					int					NOT NULL,
	SiteID					tinyint				NOT NULL,
	ResStatusID				int					NOT NULL,
	CONSTRAINT PK_ResID
	PRIMARY KEY (ResID)
)

CREATE TABLE RESERVATION_STATUS(
	ResStatusID				int	identity(1,1)	NOT NULL,
	ResStatusName			varchar(50)			NOT NULL,
	ResStatusDescription	varchar(100)			NULL,
	CONSTRAINT PK_ResStatusID
	PRIMARY KEY (ResStatusID)
)

CREATE TABLE SECURITY_ANSWER(
	AnswerID				int	identity(1,1)	NOT NULL,
	AnswerText				varchar(50)			NOT NULL,
	CustID					int					NOT NULL,
	QuestionID				tinyint				NOT NULL,
	CONSTRAINT PK_AnswerID
	PRIMARY KEY (AnswerID)
)

CREATE TABLE SECURITY_QUESTION(
	QuestionID				tinyint	IDENTITY(1,1)	NOT NULL,
	QuestionText			varchar(200)			NOT NULL,
	CONSTRAINT PK_QuestionID
	PRIMARY KEY (QuestionID)
)

CREATE TABLE SERVICE_STATUS_TYPE(
	ServiceStatusID			int	IDENTITY(1,1)	NOT NULL,
	ServiceStatusType		varchar(20)			NOT NULL,
	CONSTRAINT PK_ServiceStatusID
	PRIMARY KEY (ServiceStatusID)
)

CREATE TABLE SITE(
	SiteID					tinyint	IDENTITY(1,1)	NOT NULL,
	SiteNumber				varchar(5)				NOT NULL,
	SiteLength				tinyint					NOT NULL,
	SiteDescription			varchar(max)				NULL,
	SiteCategoryID			tinyint					NOT NULL,
	SiteLastModifiedBy		varchar(10)					NULL,
	SiteLastModifiedDate	smalldatetime				NULL,
	CONSTRAINT PK_SiteID
	PRIMARY KEY (SiteID)
)

CREATE TABLE SITE_CATEGORY(
	SiteCategoryID			tinyint	IDENTITY(1,1)	NOT NULL,
	SiteCategoryName		varchar(50)				NOT NULL,
	SiteCategoryDescription	varchar(max)				NULL,
	LocationID				int						NOT NULL,
	CONSTRAINT PK_SiteCategoryID
	PRIMARY KEY (SiteCategoryID),
	CONSTRAINT FK_LocationID
	FOREIGN KEY (LocationID) REFERENCES LOCATION (LocationID) 
)

CREATE TABLE SITE_RATE(
	RateID					int	IDENTITY(1,1)	NOT NULL,
	RateAmount				smallmoney			NOT NULL,
	RateStartDate			smalldatetime		NOT NULL,
	RateEndDate				smalldatetime		NOT NULL,
	RateLastModifiedBy		varchar(50)				NULL,
	RateLastModifiedDate	smalldatetime			NULL,
	SiteCategoryID			tinyint				NOT NULL,
	CONSTRAINT PK_RateID
	PRIMARY KEY (RateID),
	CONSTRAINT FK_SiteCategoryID
	FOREIGN KEY (SiteCategoryID) REFERENCES SITE_CATEGORY (SiteCategoryID) 
)

CREATE TABLE SPECIAL_EVENT(
	EventID					int	IDENTITY(1,1)	NOT NULL,
	EventName				varchar(50)			NOT NULL,
	EventStartDate			smalldatetime		NOT NULL,
	EventEndDate			smalldatetime		NOT NULL,
	EventDescription		varchar(max)			NULL,
	LocationID				int					NOT NULL,
	CONSTRAINT PK_EventID
	PRIMARY KEY (EventID),
	CONSTRAINT FK_LocationIDSpecialEvent
	FOREIGN KEY (LocationID) REFERENCES LOCATION (LocationID) 
)

CREATE TABLE VEHICLE_TYPE(
	TypeID					tinyint	IDENTITY(1,1)	NOT NULL,
	TypeName				varchar(50)				NOT NULL,
	TypeDescription			varchar(max)				NULL,
	CONSTRAINT PK_TypeID
	PRIMARY KEY (TypeID)
)

GO



--Foreign Keys
--------------------------------------------------------------------------------------------------------------------------

ALTER TABLE CUSTOMER
	ADD
	CONSTRAINT FK_DODAffiliationID
	FOREIGN KEY (DODAffiliationID) REFERENCES DOD_AFFILIATION_TYPE (DODAffiliationID),
	CONSTRAINT FK_ServiceStatusID
	FOREIGN KEY (ServiceStatusID) REFERENCES SERVICE_STATUS_TYPE (ServiceStatusID) 

ALTER TABLE RESERVATION
	ADD
	CONSTRAINT FK_VehicleTypeID
	FOREIGN KEY (VehicleTypeID) REFERENCES VEHICLE_TYPE (TypeID),
	CONSTRAINT FK_CustID_2
	FOREIGN KEY (CustID) REFERENCES CUSTOMER (CustID),
	CONSTRAINT FK_SiteID
	FOREIGN KEY (SiteID) REFERENCES SITE (SiteID),
	CONSTRAINT FK_ResStatusID
	FOREIGN KEY (ResStatusID) REFERENCES RESERVATION_STATUS (ResStatusID)

ALTER TABLE SECURITY_ANSWER
	ADD
	CONSTRAINT FK_CustID_3
	FOREIGN KEY (CustID) REFERENCES CUSTOMER (CustID),
	CONSTRAINT FK_QuestionID
	FOREIGN KEY (QuestionID) REFERENCES SECURITY_QUESTION (QuestionID)

ALTER TABLE SITE
	ADD
	CONSTRAINT FK_SiteCategoryID_2
	FOREIGN KEY (SiteCategoryID) REFERENCES SITE_CATEGORY (SiteCategoryID)

ALTER TABLE PAYMENT
	ADD
	CONSTRAINT FK_ResID
	FOREIGN KEY (ResID) REFERENCES RESERVATION (ResID),
	CONSTRAINT FK_ReasonID
	FOREIGN KEY (ReasonID) REFERENCES PAYMENT_REASON (PayReasonID),
	CONSTRAINT FK_PayTypeID
	FOREIGN KEY (PayTypeID) REFERENCES PAYMENT_TYPE (PayTypeID)
GO

--Check Constraints
--------------------------------------------------------------------------------------------------------------------------

--This is not good to check on this end for multiple reasons, but this is a simple check
ALTER TABLE CUSTOMER
	ADD
	CONSTRAINT CK_InvalidEmail
	CHECK (CustEmail like '%_@__%.__%')

ALTER TABLE DOD_AFFILIATION_TYPE
	ADD
	CONSTRAINT CK_ImproperDODTag
	CHECK (DODAffilationType = 'Army' OR DODAffilationType = 'Air Force' OR DODAffilationType = 'Navy' OR DODAffilationType = 'Marines' OR DODAffilationType = 'Coast Guard')

ALTER TABLE PAYMENT_TYPE
	ADD
	CONSTRAINT CK_ImproperPaymentType
	CHECK (PayType = 'Check' OR PayType = 'Cash' OR PayType = 'Card')

ALTER TABLE RESERVATION
	ADD
	--Not sure if this one will work
	CONSTRAINT CK_TooLongOfStay
	CHECK ((DATEDIFF(day, ResStartDate, ResEndDate) <= 15 AND (ResStartDate BETWEEN '04-15' AND '10-15') OR ResEndDate BETWEEN '04-16' AND '10-14')),
	CONSTRAINT CK_TooManyPets
	CHECK (ResNumPets < 2)

ALTER TABLE SERVICE_STATUS_TYPE
	ADD
	CONSTRAINT CK_ImproperServiceStatus
	CHECK (ServiceStatusType = 'Active' OR ServiceStatusType = 'Retired' OR ServiceStatusType = 'Reserves' OR ServiceStatusType = 'PCS')

ALTER TABLE VEHICLE_TYPE
	ADD
	CONSTRAINT CK_ImproperVehicleType
	CHECK (TypeName = 'Motor Home' OR TypeName = 'Travel Trailer' OR TypeName = '5th Wheel' OR TypeName = 'Pop Up' OR TypeName = 'Van' OR TypeName = 'Other')

GO


--Default Keys
--------------------------------------------------------------------------------------------------------------------------

ALTER TABLE PAYMENT
	ADD
	DEFAULT GETDATE() FOR PayDate

ALTER TABLE RESERVATION
	ADD
	DEFAULT 1 FOR ResNumAdults,
	DEFAULT 0 FOR ResNumChildren,
	DEFAULT 0 FOR ResNumPets,
	DEFAULT GETDATE() FOR ResCreatedDate

GO