USE RV_HillAirForceBase

GO

--fn_ReturnAllUnPaidReservations :: Returns a list of all unpaid reservations

IF EXISTS (SELECT * FROM sys.objects WHERE 
object_id = OBJECT_ID('dbo.fn_ReturnAllUnpaidReservations') 
AND type in (N'FN', N'IF',N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.fn_ReturnAllUnpaidReservations;

GO

--Function with one bit parameter, returns table
CREATE FUNCTION dbo.fn_ReturnAllUnpaidReservations
(@paid bit)

RETURNS TABLE

AS
RETURN

--Table returned has the payId and the isPaid status
(SELECT p.PayID, p.IsPaid
FROM PAYMENT p
WHERE IsPaid = @paid
)

GO

--Shows all reservations, paid or not
SELECT * FROM PAYMENT

--Shows the reservation that are paid
SELECT * FROM dbo.fn_ReturnAllUnpaidReservations(0);




---------------

--sp_change_rate

USE RV_HillAirForceBase

--removes upon existence
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_move_host')
	DROP PROCEDURE sp_move_host;
GO

--Creating sp_move_host with the date and site ID
CREATE PROCEDURE sp_move_host
	@GetDate	smalldatetime,
	@SiteID		tinyint
AS

BEGIN

--If the SiteID variable is also in SiteID
IF @SiteID IN
(
	SELECT SiteID
	FROM RESERVATION
)	

BEGIN
--Updates Reservation to leave a previous host comment
	UPDATE RESERVATION

	SET ResComment = 'Previous Host', ResEndDate = @GetDate
	FROM RESERVATION
	WHERE SiteID = @SiteID

	END

END

GO

--Setting up variables for executing
BEGIN TRANSACTION sp_move_host

DECLARE @SiteID tinyint, 
@GetDate smalldatetime
SELECT @SiteID = 1, @GetDate = '2025-02-04 12:34:00'

--Before the execution
SELECT * FROM RESERVATION

--Exectes the stored procedure
EXEC sp_move_host
	@SiteID = @SiteID,
	@GetDate = @GetDate

--Checks to see that the reservation was changed
SELECT * FROM RESERVATION

--ROLLBACK TRANSACTION DiscountBeverages
ROLLBACK TRANSACTION sp_move_host
GO


--------------

USE RV_HillAirForceBase
GO

--tr_Reservation_Update_Num_Pets ::  Created or Update to Reservation.  
--When pets are more than zero, verify that ResAcknowledgeValidPets is set to 1.  
--Otherwise, inform user that ResAcknowledgeValidPets must be done in order to bring pets to the site.

IF OBJECT_ID ('tr_Update_Num_Pets','TR') IS NOT NULL
	DROP TRIGGER tr_Update_Num_Pets;
GO

Create Trigger tr_Update_Num_Pets
ON RESERVATION
AFTER INSERT, UPDATE
AS
DECLARE @Pets tinyint
IF EXISTS (SELECT *
			FROM inserted i
			LEFT JOIN RESERVATION r on i.ResID = r.ResID
			WHERE r.ResNumPets > 0 AND r.ResAcknowledgeValidPets != 1)
BEGIN
RAISERROR ('Cannot complete until pet acknowledgement is done', 16, 1);
ROLLBACK TRANSACTION;
RETURN
END


UPDATE RESERVATION
SET ResNumPets = 1
WHERE ResID = 2

GO

UPDATE RESERVATION
SET ResNumPets = 1, ResAcknowledgeValidPets = 1
WHERE ResID = 5

GO

SELECT * FROM RESERVATION

