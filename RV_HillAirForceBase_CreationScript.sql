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
<<<<<<< HEAD
	CustID					int	IDENTITY(1,1)		NOT NULL,
	CustFirstName			varchar(50)				NOT NULL,
	CustLastName			varchar(50)				NOT NULL,
	CustEmail				varchar(320)			NOT NULL,
	CustPhone				varchar(15)				NOT NULL,
=======
	CustID						int	IDENTITY(1,1)		NOT NULL,
	CustFirstName				varchar(50)				NOT NULL,
	CustLastName				varchar(50)				NOT NULL,
	CustEmail					varchar(320)			NOT NULL,
	CustPhone					varchar(15)				NOT NULL,
>>>>>>> c1cb9e1b240c34538108522eda4d5f871583f1dd
	ServiceStatusID				int						NOT NULL,
	DODAffiliationID			int						NOT NULL
)

CREATE TABLE CUSTOMER_PASSWORD(
	CustID					int				NOT NULL,
	Password				varchar(40)		NOT NULL,
	Active					bit				NOT NULL,
	PasswordAssignedDate	smalldatetime	NOT NULL
)

CREATE TABLE DOD_AFFILIATION_TYPE(
	DODAffiliationID	int	IDENTITY(1,1)	NOT NULL,
	DODAffilationName	varchar(50)			NOT NULL,
)

<<<<<<< HEAD
CREATE TABLE PAYMENT(
	PayID		int IDENTITY(1,1)	NOT NULL,
	PayDate	smalldatetime     		NULL,
	PayTotalCost	smallmoney		NOT NULL,
	IsPaid			bit					NOT NULL,
	ResID	int					NOT NULL,
	ReasonID		int					NOT NULL,
	PaymentTypeID	tinyint				NOT	NULL,
	CCReference		varchar(20)				NULL,
)

CREATE TABLE PAYMENT_REASON(
	ReasonID	int	IDENTITY(1,1)	NOT NULL,
	ReasonName	varchar(20)			NOT NULL
)

=======
>>>>>>> c1cb9e1b240c34538108522eda4d5f871583f1dd
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
	PayID			int IDENTITY(1,1)	NOT NULL,
	PayDate			smalldatetime     		NULL,
	IsPaid			bit					NOT NULL,
	ReservationID	int					NOT NULL,
	ResID			int					NOT NULL,
	PaymentTypeID	tinyint					NULL,
	CCReference		varchar(20)				NULL,
)

CREATE TABLE PAYMENT_REASON(
	ReasonID	int	IDENTITY(1,1)	NOT NULL,
	ReasonName	varchar(20)			NOT NULL
)

CREATE TABLE PAYMENT_TYPE(
	PaymentTypeID	tinyint	IDENTITY(1,1)	NOT NULL,
	PaymentType		varchar(11)				NOT NULL
)

CREATE TABLE RESERVATION(
<<<<<<< HEAD
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

	VehicleTypeID					tinyint				NOT	NULL,
=======
	ResID							int	IDENTITY(1,1)	NOT NULL,
	ResNumAdults					tinyint				NOT NULL,
	ResNumChildren					tinyint				NOT NULL,
	ResNumPets						tinyint				NOT NULL,
	ResAcknowledgeValidPets			bit						NULL,
	ResStartDate					smalldatetime		NOT NULL,
	ResEndDate						smalldatetime		NOT NULL,
	ResCreatedDate					smalldatetime		NOT NULL,
	ResComment						varchar(max)			NULL,
	ResVehicleLength				tinyint					NULL,
	VehicleTypeID					tinyint					null,
>>>>>>> c1cb9e1b240c34538108522eda4d5f871583f1dd
	CustID							int					NOT NULL,
	SiteID							tinyint				NOT NULL,
	StatusID						int					NOT NULL
)

CREATE TABLE RESERVATION_STATUS(
	StatusID			int	identity(1,1)	NOT NULL,
	StatusName			varchar(50)			NOT NULL,
	StatusDescription	varchar(100)			NULL
)

CREATE TABLE SECURITY_ANSWER(
	AnswerID		int	identity(1,1)	NOT NULL,
	AnswerText		varchar(50)			NOT NULL,
<<<<<<< HEAD
	CustID		int					NOT NULL,
=======
	CustID			int					NOT NULL,
>>>>>>> c1cb9e1b240c34538108522eda4d5f871583f1dd
	QuestionID		tinyint				NOT NULL
)

CREATE TABLE SECURITY_QUESTION(
	QuestionID		tinyint	IDENTITY(1,1)	NOT NULL,
	QuestionText	varchar(200)			NOT NULL
)

CREATE TABLE SERVICE_STATUS_TYPE(
	ServiceStatusID		int	IDENTITY(1,1)	NOT NULL,
	ServiceStatusName	varchar(20)			NOT NULL,
)

CREATE TABLE SITE(
	SiteID			tinyint	IDENTITY(1,1)	NOT NULL,
	SiteNumber		varchar(5)				NOT NULL,
	SiteLength		tinyint					NOT NULL,
	SiteDescription	varchar(max)				NULL,
	SiteCategoryID	tinyint					NOT NULL,
)

CREATE TABLE SITE_CATEGORY(
<<<<<<< HEAD
	SiteCategoryID			tinyint	IDENTITY(1,1)	NOT NULL,
	SiteCategoryName		varchar(50)				NOT NULL,
	SiteCategoryDescription	varchar(max)				NULL,
	LocationID				int						NOT NULL
=======
	SiteCatID			tinyint	IDENTITY(1,1)	NOT NULL,
	SiteCatName			varchar(50)				NOT NULL,
	SiteCatDescription	varchar(max)				NULL,
	SiteCatCost			smallmoney				NOT NULL
>>>>>>> c1cb9e1b240c34538108522eda4d5f871583f1dd
)

CREATE TABLE SITE_RATE(
	RateID			int	IDENTITY(1,1)	NOT NULL,
	RateAmount		smallmoney			NOT NULL,
	RateStartDate	smalldatetime		NOT NULL,
	RateEndDate		smalldatetime		NOT NULL,
	RateLastModifiedBy	varchar(50)			NULL,
	RateLastModifiedDate	smalldatetime	NULL,
	SiteCategoryID	tinyint				NOT NULL
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
