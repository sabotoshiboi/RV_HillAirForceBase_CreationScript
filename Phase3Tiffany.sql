Use RV_HillAirForceBase

GO
--sp_charge_cancellation.  
--Accepts the input parameters @reservationID and @GetDate.  
--The Output is a smallmoney value of the amount refunded.  
--
--If the @ReservationDate < 3 days from @GetDate() then 20% of the original reservation fee will be retained, 
--and 80% will be refunded to the same method of payment in the payment table.

--Cancellations and Refunds on Reservations :: 
--More than 7 days from reservation start = full refund minus $5.00 processing fee
--3-6 days from reservation start = full refund minus $10.00 processing fee
--1-2-from reservation start = full refund minus $20.00 processing fee
--Cancellations during a Holiday and/or Special Event (stored in a data table) is automatically charged $20.00 processing fee.

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_charge_cancellation')
	DROP PROCEDURE sp_charge_cancellation;

GO

CREATE PROCEDURE sp_charge_cancellation
@resID				int,
@RefundAmount money OUTPUT
AS
	BEGIN

		declare @CurDate smalldatetime;
		declare @DateDiff int;
		declare @TotalResCost money;		--Total cost on reservation
		declare @resCreationDate smalldatetime

		set @resCreationDate = (SELECT ResCreatedDate FROM RESERVATION WHERE @resID = resID)
		set @CurDate = GetDate();
		set @DateDiff = DATEDIFF(day, @resCreationDate, @CurDate);								-- Used to determine how long since reservation was made before cancelled
		set @TotalResCost = (SELECT SUM(PayTotalCost) FROM PAYMENT as p WHERE ResID = @resID)	--Sum of all charges to customer on this reservation
		--check to see if event occured during a special event
		IF ((SELECT EventID FROM SPECIAL_EVENT as se
				JOIN Location as l
				ON l.LocationID = se.LocationID
				JOIN SITE_CATEGORY as sc
				ON sc.LocationID = l.LocationID
				JOIN Site as s
				ON s.SiteCategoryID = sc.SiteCategoryID
				JOIN Reservation as r
				ON r.SiteID = s.SiteID
				WHERE r.ResID = @resID
					AND
					(
						(r.ResEndDate >= se.EventStartDate AND r.ResEndDate <= se.EventEndDate)
						OR
						(r.ResStartDate >= se.EventStartDate AND r.ResStartDate <= se.EventEndDate)
					)
				) > 0)
				BEGIN
					--if found in special event, refund full amount - $20 processing fee
					set @RefundAmount = (@TotalResCost - 20)*-1
				END
		--else if cancellation more than 7 days from reservation start, full refund minus $20 processing fee
		ELSE IF @DateDiff >= 7
			BEGIN
				set @RefundAmount = (@TotalResCost - 20)*-1
			END
		--else if cancellation is 3-6 days from reservation start, full refund minus $10 processing fee
		ELSE IF @DateDiff >=3
			BEGIN
				set @RefundAmount = (@TotalResCost - 10)*-1
			END
		--else if cancellation is 1-2 days from reserservation start, full refund minus $5 processing fee
		ELSE
			BEGIN
				set @RefundAmount = (@TotalResCost - 5)*-1
			END
		
		-- using calculated refund amount, create new payment information
		INSERT INTO PAYMENT
		VALUES 
		(
			@CurDate,
			@RefundAmount,
			1,		-- set as paid
			NULL,	-- no cc reference for refund
			NULL,   -- no paylastmodified by
			@CurDate,
			@resID,
			(SELECT DISTINCT PayReasonID FROM PAYMENT_REASON as pr WHERE pr.PayReasonName = 'Cancellation Refund'),
			NULL	-- no pay type ID
		)
		
		RETURN		--should return refund amount
	END

GO 

-- fn_GetCustomerHistory :: Returns the history of a specific customer; 
-- including all types of reservations (Cancelled, Active, Completed, etc..)

GO

IF EXISTS (SELECT * FROM sys.objects WHERE
object_id = OBJECT_ID('fn_GetCustomerHistory')
AND type in (N'FN', N'IF',N'TF',N'FS',N'FT'))
DROP FUNCTION fn_GetCustomerHistory

GO

CREATE FUNCTION fn_GetCustomerHistory
(
	@CustID int
)
RETURNS TABLE		--Table will be of customer history
AS
RETURN
	--Returns only target fields from Reservation table
	SELECT ResID, ResNumAdults, ResNumChildren, ResNumPets, ResStartDate, ResEndDate, ResComment, ResVehicleLength, SiteID, ResStatusID FROM RESERVATION
	WHERE CustID = @CustID

GO

-- tr_Update_Res_Cancelled ::  On update to reservation status, 
-- if status is cancelled call sp_charge_cancellation

GO

IF OBJECT_ID (N'tr_update_res_cancelled') IS NOT NULL
	DROP TRIGGER tr_update_res_cancelled

GO

CREATE TRIGGER tr_update_res_cancelled ON Reservation
AFTER UPDATE
AS
	BEGIN
		declare @status varchar(50)
		declare @reservationID	int
		declare @refund money

		--set values
		set @reservationID = (SELECT resID FROM INSERTED)
		set @status = (SELECT ResStatusName FROM RESERVATION_STATUS as rs
						JOIN RESERVATION as r
						ON r.ResStatusID = rs.ResStatusID
						WHERE resID =  @reservationID)
		

		--if status of reservation is cancelled, call exec procedure sp_charge_cancellation
		IF(@status IN ('Cancelled'))
			BEGIN
				EXEC sp_charge_cancellation @resID = @reservationID, @RefundAmount = @refund
			END
	END

GO

--Indexes 

DROP INDEX IF EXISTS IX_location_city
ON LOCATION

GO

--This is a hopeful future index, with the idea that there would eventually be a large number of locations to manage
--If the number of locations grows large enough, this will allow the company to do a quick search of its localized regions
-- (Granted this may be better for the future)
CREATE UNIQUE NONCLUSTERED INDEX IX_location_city
ON LOCATION(LocationState, LocationCity, LocationName)

GO

DROP INDEX IF EXISTS IX_active_password
ON LOCATION

GO

--This would be helpful with password searches against active and non active passwords for a given customer
--Over time there will be a lot of passwords for a given customer, having this indexed will assist with password changes (and the associated checks)
--that will be searching this table
CREATE UNIQUE NONCLUSTERED INDEX IX_active_password
ON CUSTOMER_PASSWORD(CustPassID, Active DESC)

GO

DROP INDEX IF EXISTS IX_reservation_start
ON Reservation

GO

--A company would likely need to retrieve and review data concerning reservations over a select time frame
--Because there will be a lot of reservations over a long period of time, having an filter method to sort through these queries will be beneficial to the comapny
CREATE UNIQUE NONCLUSTERED INDEX IX_reservation_start
ON Reservation(ResStartDate)

GO

-- Test for tr_update_res_cancelled and sp_charge_cancellation -- uncomment to view

SELECT * FROM RESERVATION
SELECT * FROM SPECIAL_EVENT

GO

UPDATE RESERVATION 
SET ResStatusID = 2
WHERE ResID = 7

GO 

SELECT * FROM RESERVATION
SELECT * FROM PAYMENT

--Test holiday

GO

INSERT INTO PAYMENT
VALUES('2021-01-01', 1000, 1,NULL,NULL,NULL,9,1,NULL)

UPDATE RESERVATION
SET ResStatusID = 2
WHERE ResID = 9

SELECT * FROM RESERVATION
SELECT * FROM PAYMENT

--test for fn_GetCustomerHistory

SELECT * FROM fn_GetCustomerHistory(7)
			