USE master

IF EXISTS (Select * from sysdatabases where name = 'RV_HillAirForceBase')
DROP DATABASE RV_HillAirForceBase

GO

CREATE DATABASE RV_HillAirForceBase

ON PRIMARY

(
NAME = 'RV_HillAirForceBase',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\RV_HillAirForceBase.mdf',
--FILENAME LOCAL
SIZE = 12MB,
MAXSIZE = 50MB,
FILEGROWTH = 10%
)

LOG ON

(
NAME = 'RV_HillAirForceBase_Log',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\RV_HillAirForceBase.ldf',
--FILENAME LOCAL
SIZE = 12MB,
MAXSIZE = 50MB,
FILEGROWTH = 10%
)

GO

USE RV_HillAirForceBase

CREATE TABLE RESERVATION(
	ReservationID					int	IDENTITY(1,1)	not null,
	ReservationNumAdults			tinyint				not null,
	ReservationNumChildren			tinyint				not null,
	ReservationNumPets				tinyint,
	ReservationAcknowledgeValidPets	bit,
	ReservationStartDate			smalldatetime		not null,
	ReservationEndDate				smalldatetime		not null,
	ReservationCreatedDate			smalldatetime		not null,
	ReservationComment				varchar(max),
	ReservationVehicleLength		tinyint,
	VehicleTypeID					tinyint,
	CustID							int					not null,
	SiteID							tinyint				not null,
	StatusID						int					not null
)

CREATE TABLE CUSTOMER(
	CustID				int			identity(1,1)	not null,
	CustFirstName		varchar(50)					not null,
	CustLastName		varchar(50)					not null,
	CustEmail			varchar(320)				not null,
	CustPhone			varchar(15)					not null,
	CustServiceStatus	varchar(20)					not null,
	CustDODAffil		varchar(50)					not null
)

CREATE TABLE DOD_AFFILIATION_TYPE(
	DODAffiliationID	int	identity(1,1)	not null,
	DODAffilationName	varchar(50)			not null,
)

CREATE TABLE SERVICE_STATUS_TYPE(
	ServiceStatusID		int	identity(1,1)	not null,
	ServiceStatusName	varchar(20)			not null,
)

CREATE TABLE CUSTOMER_PASSWORD(
	CustID					int				not null,
	Password				varchar(40)		not null,
	Active					bit				not null,
	PasswordAssignedDate	smalldatetime	not null
)

CREATE TABLE SECURITY_ANSWER(
	AnswerID	int	identity(1,1)	not null,
	AnswerText	varchar(50)			not null,
	CustID		int					not null,
	QuestionID	tinyint				not null
)

CREATE TABLE SECURITY_QUESTION(
	QuestionID	tinyint	identity(1,1)	not null,
	QuestionText	varchar(200)		not null
)

CREATE TABLE VEHICLE_TYPE(
	TypeID			tinyint	identity(1,1)	not null,
	TypeName		varchar(50)				not null,
	TypeDescription	varchar(max)
)

CREATE TABLE SITE(
	SiteID			tinyint	identity(1,1)	not null,
	SiteName		varchar(50)				not null,
	SiteLength		tinyint					not null,
	SiteDailyCost	smallmoney				not null,
	SiteDescription	varchar(max),
	SiteCategoryID	tinyint					not null,
	LocationID		int						not null
)

CREATE TABLE SITE_CATEGORY(
	SiteCategoryID			tinyint	identity(1,1)	not null,
	SiteCategoryName		varchar(50)				not null,
	SiteCategoryDescription	varchar(max),
	SiteCategoryCost		smallmoney				not null
)

CREATE TABLE SITE_RATE(
	RateID			int	identity(1,1)	not null,
	RateName		varchar(50)			not null,
	RateAmount		smallmoney			not null,
	RateStartDate	smalldatetime		not null,
	RateEndDate		smalldatetime		not null,
	SiteID			tinyint				not null
)

CREATE TABLE LOCATION(
	LocationID			int	identity(1,1)	not null,
	LocationName		varchar(100)		not null,
	LocationAddress1	varchar(150)		not null,
	LocationAddress2	varchar(150)		not null,
	LocationCity		varchar(50)			not null,
	LocationState		varchar(20)			not null,
	LocationZip			varchar(10)			not null
)

CREATE TABLE SPECIAL_EVENT(
	EventID				int	identity(1,1)	not null,
	EventName			varchar(50)			not null,
	EventDate			smalldatetime		not null,
	EventDescription	varchar(max),
	LocationID			int					not null
)

CREATE TABLE RESERVATION_STATUS(
	StatusID			int	identity(1,1)	not null,
	StatusName			varchar(50)			not null,
	StatusDescription	varchar(100)
)

CREATE TABLE INVOICE(
	InvID			int identity(1,1)	not null,
	InvSentDate		smalldatetime		not null,
	InvPaidDate		smalldatetime,
	IsPaid			bit					not null,
	ReservationID	int					not null,
	ReasonID		int					not null,
	CCReference		varchar(20),
	FeeID			int					not null
)

CREATE TABLE INVOICE_REASON(
	ReasonID	int			not null,
	ReasonName	varchar(20)	not null
)

CREATE TABLE FEE(
	FeeID			int			not null,
	FeeAmount		smallmoney	not null,
	FeeDescription	varchar(25),
)
