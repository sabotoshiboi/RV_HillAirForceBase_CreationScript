USE RV_HillAirForceBase

GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------
--STORED PROCEDURES-------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------

--Justin Newman
--sp_cancel_reservation
--accepts input param of @ReservationID
--updates the RESERVATION record to have ResStatusID 2
--updates the ResLastModifiedBy to the current SYSTEM_USER name (after 'DOMAIN\')
--updates ResLastModifiedDate to GetDate()

DROP PROC IF EXISTS sp_cancel_reservation

GO

CREATE PROC sp_cancel_reservation (@ReservationID int)

AS
BEGIN

DECLARE @ErrMessage VARCHAR(max)
DECLARE @User VARCHAR(10) = RIGHT(SYSTEM_USER, len(SYSTEM_USER) - charindex('\', SYSTEM_USER))

    BEGIN TRY
        
        IF NOT EXISTS(SELECT * FROM RESERVATION Where ResID = @ReservationID)
        BEGIN
            SET @ErrMessage = ('"' + @ReservationID + '"' + ' is not a valid ReservationID.')
            RAISERROR (@ErrMessage, -1, -1)
            RETURN -1
        END
    END TRY
    BEGIN CATCH
    RETURN -1
    END CATCH

    UPDATE RESERVATION
    SET ResStatusID = 2, ResLastModifiedBy = @User, ResLastModifiedDate = GETDATE()
    WHERE ResID = @ReservationID

END 

GO

BEGIN TRAN
    EXEC sp_cancel_reservation
    @ReservationID = 1

    SELECT ResStatusID, ResLastModifiedBy, ResLastModifiedDate
    FROM RESERVATION
    WHERE ResID = 1
ROLLBACK


--Justin Newman
--sp_change_password
--accepts input params of @newPassword and @customerID
--creates a new record tied to the customer, deletes any existing inactive records more than 3 passwords old
--deactivates the current active password

DROP PROC IF EXISTS sp_change_password

GO

CREATE PROC sp_change_password (@newPassword VARCHAR(40), @customerID INT)

AS
BEGIN

    DECLARE @ErrMessage VARCHAR(max)

    BEGIN TRY
        
        IF NOT EXISTS(SELECT * FROM CUSTOMER Where CustID = @customerID)
        BEGIN
            SET @ErrMessage = ('"' + @customerID + '"' + ' is not a valid CustID.')
            RAISERROR (@ErrMessage, -1, -1)
            RETURN -1
        END
    END TRY
    BEGIN CATCH
    RETURN -1
    END CATCH

    BEGIN TRAN
        UPDATE CUSTOMER_PASSWORD
        SET Active = 0
        WHERE CustPassID IN (
            SELECT CustPassID FROM CUSTOMER_PASSWORD 
            WHERE CustID = @customerID AND Active = 1
        )

        INSERT INTO CUSTOMER_PASSWORD
        VALUES (@customerID, @newPassword, 1, GETDATE())

        DELETE FROM CUSTOMER_PASSWORD
        WHERE CustID = @customerID AND CustPassID NOT IN (
            SELECT TOP 3 CustPassID
            FROM CUSTOMER_PASSWORD
            WHERE CustID = @customerID
            ORDER BY PasswordAssignedDate DESC
        )
    COMMIT
END
GO

BEGIN TRAN
    EXEC  sp_change_password
    @newPassword = 'password2',
    @customerID = 7
ROLLBACK


SELECT * FROM CUSTOMER_PASSWORD
WHERE CustID = 7

--Austin Langston
--sp_charge_fee
--Accepts the input parameters @ReservationID and @ReasonID.  
--Creates a new PAYMENT record tied to a reservation.  
GO
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_charge_fee')
DROP PROCEDURE sp_charge_fee;

GO

CREATE PROC sp_charge_fee
	@ReservationID	int,
	@ReasonID		int,
	@TotalCost		int,
	@PayTypeID		int

AS
	BEGIN

	INSERT INTO Payment(PayDate, PayTotalCost, IsPaid, ResID, ReasonID, PayTypeID)
	VALUES(GETDATE(), @TotalCost, 0, @ReservationID, @ReasonID, @PayTypeID)

	PRINT 'Inserted new Payment to database'

	END

GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------
--FUNCTIONS---------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------

--Justin Newman
--fn_CheckSecurityQuestion :: Returns an answer if the security question is correct without displaying the correct answer

DROP FUNCTION IF EXISTS fn_CheckSecurityQuestion

GO

CREATE FUNCTION dbo.fn_CheckSecurityQuestion (
    @CustomerID as INT,
    @QuestionID as tinyint, 
    @AttemptedAnswer as VARCHAR(50)
)
RETURNS VARCHAR(9)

AS
BEGIN

DECLARE @Result VARCHAR(9)

IF @AttemptedAnswer = (
    SELECT AnswerText
    FROM SECURITY_ANSWER
    WHERE CustID = @CustomerID AND QuestionID = @QuestionID
)
    SET @Result = 'Correct'
ELSE
    SET @Result = 'Incorrect'

RETURN @Result

END

GO

SELECT dbo.fn_CheckSecurityQuestion(7,1,'Inhuman Dave') as 'Incorrect Answer Attempt'
SELECT dbo.fn_CheckSecurityQuestion(7,1,'Human Dave') as 'Correct Answer Attempt'

--Austin Langston
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

--------------------------------------------------------------------------------------------------------------------------------------------------------------
--TRIGGERS----------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------

--Justin Newman
--tr_Password_Check :: On creation, make sure new password is not one of most recent 3 old passwords

DROP TRIGGER IF EXISTS [dbo].[tr_Password_Check];

GO

CREATE TRIGGER tr_Password_Check ON [CUSTOMER_PASSWORD]
AFTER INSERT
AS
DECLARE @errorMsg VARCHAR(max)
SET @errorMsg = 'Password already used too recently'
BEGIN
    IF EXISTS(
        SELECT *
        FROM CUSTOMER_PASSWORD
        WHERE CustID = (SELECT CustID FROM inserted) 
        AND [Password] = (SELECT [Password] from inserted)
        HAVING COUNT(*) > 1
    )
        BEGIN
            RAISERROR(@errorMsg, 16, 1)
            ROLLBACK
        END
END

GO

BEGIN TRAN
    SELECT [Password] FROM CUSTOMER_PASSWORD
    WHERE CustID = 7

    INSERT INTO CUSTOMER_PASSWORD(CustID, [Password], Active, [PasswordAssignedDate])
    VALUES(7, 'password', 1, GETDATE())
ROLLBACK

--Austin Langston
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
		Raiserror ('Cannot insert, needs CCReference for card payments', 16, 1) 
		ROLLBACK TRAN
	END

GO