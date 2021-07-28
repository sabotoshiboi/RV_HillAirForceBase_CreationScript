USE RV_HillAirForceBase
-- sp_charge_fee
--  Accepts the input parameters @ReservationID and @ReasonID.  
--  Creates a new PAYMENT record tied to a reservation.  
GO
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_charge_fee')
DROP PROCEDURE sp_charge_fee;

GO

CREATE PROC sp_charge_fee
	@ReservationID	int,
	@ReasonID		int,
	@TotalCost		int,
	@PayTypeID		int,
	@CCReference	varchar(20) null

AS
	BEGIN

	IF ( (@PayTypeID = 1 AND @CCReference IS NOT NULL) OR (@PayTypeID != 1))
		BEGIN
		INSERT INTO Payment(PayDate, PayTotalCost, IsPaid, ResID, ReasonID, PayTypeID)
		VALUES(GETDATE(), @TotalCost, 0, @ReservationID, @ReasonID, @PayTypeID)

		PRINT 'Inserted new Payment to database'
		END
	ELSE 
		BEGIN
			PRINT 'PayTypeID Requires CCReference'
		END

	END

GO

SELECT * FROM PAYMENT_REASON
EXEC sp_charge_fee 
	@ReservationID = 1,
	@ReasonID	   = 2,
	@TotalCost	   = 1,
	@PayTypeID	   = 2,
	@CCReference   = null

EXEC sp_charge_fee 
	@ReservationID = 1,
	@ReasonID	   = 2,
	@TotalCost	   = 1,
	@PayTypeID	   = 1,
	@CCReference   = null

-- fn_GetCustomerPayments :: Returns all receipts of customer payments and outstanding balances for a specific customer
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.fn_GetCustomerPayments') 
AND type in (N'FN', N'IF',N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.fn_GetCustomerPayments;

GO

CREATE FUNCTION dbo.fn_GetCustomerPayments(@CustomerID int)
RETURNS TABLE
AS

RETURN
SELECT PayID, PayDate, PayTotalCost, PayType, IsPaid FROM PAYMENT
LEFT JOIN PAYMENT_TYPE on PAYMENT_TYPE.PayTypeID = PAYMENT.PayTypeID
LEFT JOIN RESERVATION on RESERVATION.ResID = PAYMENT.ResID
WHERE CustID = @CustomerID

GO

SELECT * FROM fn_GetCustomerPayments(1)

-- tr_Payment_PayTypeID :: On creation (or, if not required - then update) - if payment PayTypeID is a card, require a CCReference to be filled in as well.
DROP TRIGGER IF EXISTS dbo.tr_Payment_PayTypeID

GO

Create Trigger tr_Payment_PayTypeID ON PAYMENT
AFTER UPDATE, INSERT
AS

	-- If updated to card payment
	IF (UPDATE (PaytypeID) AND NOT UPDATE (CCReference))
	BEGIN 
		-- Assuming we make card payments ID of 1
		IF ((SELECT PayTypeID FROM inserted) = 1)
		BEGIN
			Raiserror ('Cannot update, needs CCReference for card payments', 16, 1) 
			ROLLBACK TRAN
		END
	END

	-- If just inserted
	ELSE IF ((SELECT PayTypeID FROM inserted) = 1)
	BEGIN
		IF ((SELECT CCReference FROM inserted) IS NULL)
		BEGIN
			Raiserror ('Cannot insert, needs CCReference for card payments', 16, 1) 
			ROLLBACK TRAN
		END
	END

GO