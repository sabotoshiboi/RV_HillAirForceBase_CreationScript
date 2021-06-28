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

CREATE TABLE CUSTOMER(
	CustomerID					int	IDENTITY(1,1)		NOT NULL,
	CustomerFirstName			varchar(50)				NOT NULL,
	CustomerLastName			varchar(50)				NOT NULL,
	CustomerEmail				varchar(320)			NOT NULL,
	CustomerPhone				varchar(15)				NOT NULL,
	ServiceStatusID				int						NOT NULL,
	DODAffiliationID			int						NOT NULL
)

CREATE TABLE CUSTOMER_PASSWORD(
	CustomerID				int				NOT NULL,
	Password				varchar(40)		NOT NULL,
	Active					bit				NOT NULL,
	PasswordAssignedDate	smalldatetime	NOT NULL
)

CREATE TABLE DOD_AFFILIATION_TYPE(
	DODAffiliationID	int	IDENTITY(1,1)	NOT NULL,
	DODAffilationName	varchar(50)			NOT NULL,
)

CREATE TABLE INVOICE(
	InvoiceID		int IDENTITY(1,1)	NOT NULL,
	InvoiceSentDate	smalldatetime		NOT NULL,
	InvoicePaidDate	smalldatetime     		NULL,
	IsPaid			bit					NOT NULL,
	ReservationID	int					NOT NULL,
	ReasonID		int					NOT NULL,
	PaymentTypeID	tinyint					NULL,
	CCReference		varchar(20)				NULL,
--  FeeID			int					NOT NULL
)

CREATE TABLE INVOICE_REASON(
	ReasonID	int	IDENTITY(1,1)	NOT NULL,
	ReasonName	varchar(20)			NOT NULL
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

CREATE TABLE PAYMENT_TYPE(
	PaymentTypeID	tinyint	IDENTITY(1,1)	NOT NULL,
	PaymentType		varchar(11)				NOT NULL
)

CREATE TABLE RESERVATION(
	ReservationID					int	IDENTITY(1,1)	NOT NULL,
	ReservationNumAdults			tinyint				NOT NULL,
	ReservationNumChildren			tinyint				NOT NULL,
	ReservationNumPets				tinyint				NOT NULL,
	ReservationAcknowledgeValidPets	bit						NULL,
	ReservationStartDate			smalldatetime		NOT NULL,
	ReservationEndDate				smalldatetime		NOT NULL,
	ReservationCreatedDate			smalldatetime		NOT NULL,
	ReservationComment				varchar(max)			NULL,
	ReservationVehicleLength		tinyint					NULL,
	VehicleTypeID					tinyint					null,
	CustomerID						int					NOT NULL,
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
	CustomerID		int					NOT NULL,
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
	SiteName		varchar(50)				NOT NULL,
	SiteLength		tinyint					NOT NULL,
	SiteDailyCost	smallmoney				NOT NULL,
	SiteDescription	varchar(max)				NULL,
	SiteCategoryID	tinyint					NOT NULL,
--	LocationID		int						NOT NULL
)

CREATE TABLE SITE_CATEGORY(
	SiteCategoryID			tinyint	IDENTITY(1,1)	NOT NULL,
	SiteCategoryName		varchar(50)				NOT NULL,
	SiteCategoryDescription	varchar(max)				NULL,
	SiteCategoryCost		smallmoney				NOT NULL
)

CREATE TABLE SITE_RATE(
	RateID			int	IDENTITY(1,1)	NOT NULL,
	RateName		varchar(50)			NOT NULL,
	RateAmount		smallmoney			NOT NULL,
	RateStartDate	smalldatetime		NOT NULL,
	RateEndDate		smalldatetime		NOT NULL,
	SiteCategoryID	tinyint				NOT NULL
)

CREATE TABLE SPECIAL_EVENT(
	EventID				int	IDENTITY(1,1)	NOT NULL,
	EventName			varchar(50)			NOT NULL,
	EventDate			smalldatetime		NOT NULL,
	EventDescription	varchar(max)			NULL,
	LocationID			int					NOT NULL
)

CREATE TABLE VEHICLE_TYPE(
	TypeID			tinyint	IDENTITY(1,1)	NOT NULL,
	TypeName		varchar(50)				NOT NULL,
	TypeDescription	varchar(max)				NULL
)

-- CREATE TABLE FEE(
-- 	FeeID			int			NOT NULL,
-- 	FeeAmount		smallmoney	NOT NULL,
-- 	FeeDescription	varchar(25)		NULL,
-- )
