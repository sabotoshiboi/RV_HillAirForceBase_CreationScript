--Insert Lookup Tables
--Power Rangers
--6/28/21

USE RV_HillAirForceBase

DELETE FROM DOD_AFFILIATION_TYPE;
DBCC CHECKIDENT ('DOD_AFFILIATION_TYPE', RESEED, 0)

GO
-- Insert rows into table 'DOD_AFFILIATION_TYPE'
INSERT INTO DOD_AFFILIATION_TYPE
(
 [DODAffilationType]
)
VALUES ('Army'), ('Air Force'), ('Navy'), ('Marines'), ('Coast Guard')

GO


DELETE FROM SERVICE_STATUS_TYPE;
DBCC CHECKIDENT ('SERVICE_STATUS_TYPE', RESEED, 0)

GO
-- Insert rows into table 'SERVICE_STATUS_TYPE'
INSERT INTO SERVICE_STATUS_TYPE
(
 [ServiceStatusType]
)
VALUES ('Active'), ('Retired'), ('Reserves'), ('PCS')

GO


DELETE FROM PAYMENT_REASON;
DBCC CHECKIDENT ('PAYMENT_REASON', RESEED, 0)

GO
-- Insert rows into table 'PAYMENT_REASON'
INSERT INTO PAYMENT_REASON
(
 [PayReasonName]
)
VALUES ('Reservation Payment'), ('Damage'), ('Violation')

GO


DELETE FROM PAYMENT_TYPE;
DBCC CHECKIDENT ('PAYMENT_TYPE', RESEED, 0)

GO
-- Insert rows into table 'PAYMENT_TYPE'
INSERT INTO PAYMENT_TYPE
(
 [PayType]
)
VALUES ('Card'), ('Cash'), ('Check')

GO


DELETE FROM RESERVATION_STATUS;
DBCC CHECKIDENT ('RESERVATION_STATUS', RESEED, 0)

GO 
-- Insert rows into table 'RESERVATION_STATUS'
INSERT INTO RESERVATION_STATUS
(
 [ResStatusName]
)
VALUES ('Scheduled'), ('Cancelled'), ('Completed')

GO

INSERT INTO RESERVATION_STATUS
(
 [ResStatusName], [ResStatusDescription]
)
VALUES ('Ongoing', 'Customer is expected to be on the campsite now.')

GO


DELETE FROM VEHICLE_TYPE;
DBCC CHECKIDENT ('VEHICLE_TYPE', RESEED, 0)

GO

-- Insert rows into table 'VEHICLE_TYPE'
INSERT INTO VEHICLE_TYPE
(
 [TypeName]
)
VALUES ('Motor Home'), ('Travel Trailer'), ('5th Wheel'), ('Pop Up')

GO

INSERT INTO VEHICLE_TYPE
(
 [TypeName], [TypeDescription]
)
VALUES ('Van', 'Preferred vehicle for living down by a river')

GO

INSERT INTO VEHICLE_TYPE
(
 [TypeName]
)
VALUES ('Other')

GO