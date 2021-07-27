Use RV_HillAirForceBase

/*
sp_update_security_answer
  accepts input params of @CustomerID, @QuestionID, @AnswerText
  updates the existing answer for that passed-in customer for the passed-in question

*/

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_update_security_answer')
	DROP PROCEDURE sp_update_security_answer
GO

CREATE PROCEDURE sp_update_security_answer
	@CustomerID int,
	@QuestionID tinyint,
	@AnswerText varchar(50)
	AS
	BEGIN
		UPDATE SECURITY_ANSWER
		SET AnswerText = @AnswerText
		FROM SECURITY_ANSWER sa
		JOIN CUSTOMER c ON sa.CustID = c.CustID
		JOIN SECURITY_QUESTION sq ON sq.QuestionID = sa.QuestionID
		WHERE sa.CustID = @CustomerID AND sq.QuestionID = @QuestionID
	END

exec sp_update_security_answer @customerID = 7, @QuestionID = 3, @AnswerText = 'I hope this works'
select * from SECURITY_ANSWER

/*
fn_GetReservationHistory :: Returns the history of reservations in a specific time frame
*/

IF EXISTS (SELECT * FROM sys.objects WHERE
object_id = OBJECT_ID('dbo.fn_GetReservationHistory')
AND type in (N'FN', N'IF',N'TF',N'FS',N'FT'))
DROP FUNCTION dbo.fn_GetReservationHistory

GO

CREATE FUNCTION dbo.fn_GetReservationHistory(@TimeBegin date, @TimeEnd date)
	returns @HistoryTable table(
	ResID					int					NOT NULL,
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
	AS
	BEGIN
		INSERT @HistoryTable
		SELECT *
		FROM RESERVATION
		WHERE ResStartDate BETWEEN @TimeBegin AND @TimeEnd
		RETURN

	END
GO

select *
from dbo.fn_GetReservationHistory('2021-09-15', '2021-12-15')

/*
tr_Limit_Reservation_Time :: On Reservation creation or an update to Reservation Start Date/ End Date, 
verify that the reservation is limited to 15 days if between April 15 - Oct 15.  
No other restrictions on length of stay.
*/

IF EXISTS (SELECT * FROM sys.triggers 
           WHERE Name = 'tr_Limit_Reservation_Time')
		   DROP trigger tr_Limit_Reservation_Time
go

CREATE TRIGGER tr_Limit_Reservation_Time ON Reservation
AFTER INSERT, UPDATE
AS
BEGIN

	IF EXISTS(SELECT *
	FROM inserted i
	
	WHERE --DATEPART(MONTH, i.ResStartDate) Between DATEPART(MONTH, '2021-4-15') AND DATEPART(MONTH, '2021-10-15')
	--AND DATEPART(MONTH, i.ResEndDate) Between DATEPART(MONTH,'2021-4-15') AND DATEPART(MONTH, '2021-10-15')

	DATEDIFF(day, '2021-1-1', i.ResStartDate) >= DATEDIFF(DAY, '2021-1-1', '2021-4-14')
	AND DATEDIFF(day, '2021-1-1', i.ResStartDate) <= DATEDIFF(DAY, '2021-1-1', '2021-10-15')

	AND DATEDIFF(day, i.ResStartDate, i.ResEndDate) > 15
	)
	BEGIN
		UPDATE RESERVATION
		SET ResEndDate = DATEADD(DAY, 15, r.ResStartDate)
		from RESERVATION r
		Join inserted i ON i.ResID = r.ResID
		where r.ResID = i.ResID

		PRINT 'RESERVATION IS TOO LONG, DEFAULTING TO 15 DAY MAXIMUM'
	END
END

go

select *
from RESERVATION

Insert into RESERVATION
values(1, 1, 1, 1, '2021-4-15', '2021-5-15', GETDATE(), 'meh', 22, 'tb', GETDATE(), 1, 1, 9, 1)

select *
from RESERVATION

/*
cursor_update_site_by_location :: Updates all the site numbers in a certain location. Used if the owner ever wants to change the numbering system.
@location is what location you want the sites numbering system updated
@increment is the differece between each site number
@basenumber is what you want the new SiteNumber system to be based on.
*/



declare @location int
set @location = 1

declare cursor_update_site_by_location cursor
for
	select distinct SiteID
	from SITE S
	JOIN SITE_CATEGORY SC ON SC.SiteCategoryID = S.SiteCategoryID
	JOIN LOCATION L ON L.LocationID = SC.LocationID
	WHERE SC.LocationID = @location
GO

declare @increment int
declare @basenumber int
declare @sitenum varchar(max)

SET @increment = 1
SET @basenumber = 100
open cursor_update_site_by_location

fetch next from cursor_update_site_by_location
into @sitenum


while @@FETCH_STATUS = 0
begin
	UPDATE SITE
	set SiteNumber = Cast(@basenumber as Varchar)
	where SiteID = @sitenum
	set @basenumber = @basenumber + @increment

	fetch next from cursor_update_site_by_location
	into @sitenum
end

close cursor_update_site_by_location
deallocate cursor_update_site_by_location
GO

select SiteID, SiteNumber, l.LocationID
	from SITE S
	JOIN SITE_CATEGORY SC ON SC.SiteCategoryID = S.SiteCategoryID
	JOIN LOCATION L ON L.LocationID = SC.LocationID
	where l.LocationID = 1
	


