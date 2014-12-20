-- Get current identity
DBCC CHECKIDENT ('Advertising.Spots', NORESEED)
SELECT MAX(SpotID) FROM Advertising.Spots

-- Reseed
DBCC CHECKIDENT ('Advertising.Spots', RESEED, 215734)