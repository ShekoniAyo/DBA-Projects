-- Borrowings indexes — dbo schema (not moved)
CREATE INDEX IX_Borrowings_MemberID
ON dbo.Borrowings(member_id);

CREATE INDEX IX_Borrowings_CopyID
ON dbo.Borrowings(copy_id);

CREATE INDEX IX_Borrowings_StaffID
ON dbo.Borrowings(staff_id);

CREATE INDEX IX_Borrowings_BorrowDate
ON dbo.Borrowings(borrow_date);

-- Fines indexes — sensitive schema
CREATE INDEX IX_Fines_BorrowID
ON sensitive.Fines(borrow_id);

CREATE INDEX IX_Fines_PaymentStatus
ON sensitive.Fines(payment_status);

-- Members indexes — sensitive schema
-- IX_Members_Email skipped — already covered by UQ_Members_Email
CREATE INDEX IX_Members_Status
ON sensitive.Members(status);

CREATE INDEX IX_Members_ExpiryDate
ON sensitive.Members(expiry_date);

-- Copies indexes — dbo schema (not moved)
CREATE INDEX IX_Copies_Availability
ON dbo.Copies(availability);

CREATE INDEX IX_Copies_BookID
ON dbo.Copies(book_id);
