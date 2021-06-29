USE master

IF EXISTS (Select * from sysdatabases where name = 'RV_HillAirForceBase')
DROP DATABASE RV_HillAirForceBase

GO

CREATE DATABASE RV_HillAirForceBase

ON PRIMARY

(
NAME = 'RV_HillAirForceBase',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\RV_HillAirForceBase.mdf', --Change to your own directory
--FILENAME LOCAL
SIZE = 12MB,
MAXSIZE = 50MB,
FILEGROWTH = 10%
)

LOG ON

(
NAME = 'RV_HillAirForceBase_Log',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\RV_HillAirForceBase.ldf', --Change to your own directory
--FILENAME LOCAL
SIZE = 12MB,
MAXSIZE = 50MB,
FILEGROWTH = 10%
)

GO

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
	DODAffiliationID		int						NOT NULL
)

CREATE TABLE CUSTOMER_PASSWORD(
	CustID					int				NOT NULL,
	Password				varchar(40)		NOT NULL,
	Active					bit				NOT NULL,
	PasswordAssignedDate	smalldatetime	NOT NULL
)

CREATE TABLE DOD_AFFILIATION_TYPE(
	DODAffiliationID	int	IDENTITY(1,1)	NOT NULL,
	DODAffilationType	varchar(50)			NOT NULL
)

CREATE TABLE LOCATION(
	LocationID			int	IDENTITY(1,1)	NOT NULL,
	LocationName		varchar(100)		NOT NULL,
	LocationAddress1	varchar(150)		NOT NULL,
	LocationAddress2	varchar(150)			NULL,
	LocationCity		varchar(50)			NOT NULL,
	LocationState		varchar(20)			NOT NULL,
	LocationZip			varchar(10)			NOT NULL
)

CREATE TABLE PAYMENT(
	PayID				int IDENTITY(1,1)	NOT NULL,
	PayDate				smallmoney     		NOT NULL,
	IsPaid				bit					NOT NULL,
	ResID				int					NOT NULL,
	PayTypeID			tinyint				NOT NULL,
	CCReference			varchar(20)				NULL,
	PayLastModifiedBy	varchar(10)				NULL,
	PayLastModifiedDate	smalldatetime			NULL
)

CREATE TABLE PAYMENT_REASON(
	PayReasonID		int	IDENTITY(1,1)	NOT NULL,
	PayReasonName	varchar(20)			NOT NULL
)

CREATE TABLE PAYMENT_TYPE(
	PayTypeID	tinyint	IDENTITY(1,1)	NOT NULL,
	PayType		varchar(11)				NOT NULL
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
	ResStatusID				int					NOT NULL
)

CREATE TABLE RESERVATION_STATUS(
	ResStatusID			int	identity(1,1)	NOT NULL,
	ResStatusName			varchar(50)			NOT NULL,
	ResStatusDescription	varchar(100)			NULL
)

CREATE TABLE SECURITY_ANSWER(
	AnswerID		int	identity(1,1)	NOT NULL,
	AnswerText		varchar(50)			NOT NULL,
	CustID			int					NOT NULL,
	QuestionID		tinyint				NOT NULL
)

CREATE TABLE SECURITY_QUESTION(
	QuestionID		tinyint	IDENTITY(1,1)	NOT NULL,
	QuestionText	varchar(200)			NOT NULL
)

CREATE TABLE SERVICE_STATUS_TYPE(
	ServiceStatusID		int	IDENTITY(1,1)	NOT NULL,
	ServiceStatusType	varchar(20)			NOT NULL
)

CREATE TABLE SITE(
	SiteID					tinyint	IDENTITY(1,1)	NOT NULL,
	SiteNumber				varchar(5)				NOT NULL,
	SiteLength				tinyint					NOT NULL,
	SiteDescription			varchar(max)				NULL,
	SiteCategoryID			tinyint					NOT NULL,
	SiteLastModifiedBy		varchar(10)					NULL,
	SiteLastModifiedDate	smalldatetime				NULL
)

CREATE TABLE SITE_CATEGORY(
	SiteCategoryID			tinyint	IDENTITY(1,1)	NOT NULL,
	SiteCategoryName		varchar(50)				NOT NULL,
	SiteCategoryDescription	varchar(max)				NULL,
	LocationID				int						NOT NULL
)

CREATE TABLE SITE_RATE(
	RateID					int	IDENTITY(1,1)	NOT NULL,
	RateAmount				smallmoney			NOT NULL,
	RateStartDate			smalldatetime		NOT NULL,
	RateEndDate				smalldatetime		NOT NULL,
	RateLastModifiedBy		varchar(50)				NULL,
	RateLastModifiedDate	smalldatetime			NULL,
	SiteCategoryID			tinyint				NOT NULL
)

CREATE TABLE SPECIAL_EVENT(
	EventID				int	IDENTITY(1,1)	NOT NULL,
	EventName			varchar(50)			NOT NULL,
	EventStartDate		smalldatetime		NOT NULL,
	EventEndDate		smalldatetime		NOT NULL,
	EventDescription	varchar(max)			NULL,
	LocationID			int					NOT NULL
)

CREATE TABLE VEHICLE_TYPE(
	TypeID			tinyint	IDENTITY(1,1)	NOT NULL,
	TypeName		varchar(50)				NOT NULL,
	TypeDescription	varchar(max)				NULL
)
