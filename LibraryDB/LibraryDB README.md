# 📚 Small Town Library Database System

A relational database system built in **SQL Server** to manage the core operations of a small-town library — including book cataloguing, member registration, borrowing transactions, and fine management.

---

## 📌 Project Overview

This database was designed to reflect real-world library operations. The goal was not just to store data, but to enforce business rules, ensure data integrity, and provide meaningful reporting for library staff and management.

**Key capabilities:**
- Track books, physical copies, and their availability
- Manage member registrations and membership validity
- Process borrowing and return transactions with full accountability
- Automatically calculate and record fines for overdue returns
- Generate operational and management reports

---

## 🗂️ Database Schema

The database consists of **9 tables** designed in dependency order to respect foreign key constraints.

### Entity Overview

| Table | Description |
|---|---|
| `Genre` | Lookup table for book genres |
| `Authors` | Stores author information |
| `Books` | Core book catalogue with ISBN and genre |
| `BookAuthors` | Junction table linking books to authors (many-to-many) |
| `Copies` | Individual physical copies of each book |
| `Members` | Registered library members |
| `Staff` | Library staff who process transactions |
| `Borrowings` | Records of all borrowing transactions |
| `Fines` | Fines issued for overdue returns |


---

## ⚙️ Functions

Three scalar functions encapsulate reusable business logic, keeping procedures clean and consistent.

### `fn_IsMembershipValid`
Returns `1` if a member's status is Active and their membership has not expired, `0` otherwise. Used in the borrow procedure to validate eligibility.

### `fn_DaysOverdue`
Accepts a due date and return date, returns the number of days overdue as an integer. Uses `COALESCE` to substitute today's date when a book hasn't been returned yet, making it accurate for both historical and active borrowings. Returns `0` for on-time returns.

### `fn_MemberOutstandingFines`
Returns the total outstanding fine amount for a member in `DECIMAL(7,2)`. Combines two sources:
1. Unpaid fines already recorded in the Fines table
2. Accrued fines for currently overdue active borrowings not yet returned

This ensures the borrow validation reflects what a member actually owes, not just what has been formally recorded.

---

## 🔄 Stored Procedures — Transactions

### `usp_BorrowBook`
Processes a book borrowing transaction.

**Parameters:** `@member_id`, `@book_id`, `@copy_id`, `@staff_id`

**Validation sequence:**
1. Member exists
2. Membership is active and not expired — via `fn_IsMembershipValid`
3. Member's outstanding fines are below NGN 300.00 — via `fn_MemberOutstandingFines`
4. Book exists in the catalogue
5. Specified copy exists, belongs to the book, and is available

**On success:** Inserts a borrowing record with `borrow_date = today` and `date_due = today + 14 days`, updates copy availability to 0. Both actions are wrapped in a single transaction.

---

### `usp_ReturnBook`
Processes a book return and issues a fine if overdue.

**Parameters:** `@borrow_id`

**Validation:** Confirms an active borrowing exists with a NULL return date.

**On success:** Updates the borrowing record with today's return date, restores copy availability to 1, and inserts a fine record if the return is past the due date. All three actions are wrapped in a single transaction.

---

### `usp_RegisterMember`
Registers a new library member.

**Parameters:** `@first_name`, `@last_name`, `@address`, `@phone_no`, `@DOB`, `@gender`, `@email`

**Validation sequence:**
1. Phone number is exactly 11 digits
2. Member is at least 18 years old
3. Email does not already exist in the system

**On success:** Inserts member with `status = 'Active'`, `reg_date = today`, and `expiry_date = 6 months from today`.

---

## 📊 Stored Procedures — Reports

### `usp_Report_Borrowings`
Returns all borrowing records within a date range.

**Parameters:** `@start_date`, `@end_date` *(defaults to 3 months after start date)*

**Validations:** Start date not in the future, end date not before start date.

---

### `usp_Report_MostBorrowedBooks`
Returns books ranked by borrowing frequency within a date range, optionally filtered by genre.

**Parameters:** `@start_date`, `@end_date` *(defaults to 3 months after start date)*, `@genre` *(optional)*

**Validations:** Same date validations as above.

---

### `usp_Report_OutstandingFines`
Returns a list of all unpaid fines with full member contact details and days outstanding — designed as an actionable follow-up list for library staff.

**Parameters:** None — fixed report.

---

### `usp_Report_StaffTransactions`
Returns transaction counts per staff member within a date range.

**Parameters:** `@start_date`, `@end_date` *(defaults to 3 months after start date)*, `@staff_id` *(optional — omit to see all staff)*

**Validations:** Same date validations as above.

---

## 👁️ Views

| View | Description |
|---|---|
| `vw_MemberCount` | Member counts grouped by status (Active, Expired, Inactive) |
| `vw_BookCatalogue` | Full catalogue with genre and authors aggregated into a single field using `STRING_AGG` |
| `vw_CopiesAvailability` | Available copy counts per book |
| `vw_BooksNeverBorrowed` | Books with no borrowing history — useful for collection review |
| `vw_MostActiveMembers` | Top 10 members by borrowing frequency with membership duration |

---

## 🔍 Indexes

Indexes were applied selectively to columns that are frequently filtered or joined against, balancing read performance against write overhead.

| Index | Table | Column | Justification |
|---|---|---|---|
| `IX_Borrowings_MemberID` | Borrowings | member_id | Fine checks and validation query this constantly |
| `IX_Borrowings_CopyID` | Borrowings | copy_id | Availability checks on every borrow and return |
| `IX_Borrowings_StaffID` | Borrowings | staff_id | Staff transaction reports filter by this |
| `IX_Borrowings_BorrowDate` | Borrowings | borrow_date | All date range reports filter against this |
| `IX_Fines_BorrowID` | Fines | borrow_id | Foreign key joins — not auto-indexed in SQL Server |
| `IX_Fines_PaymentStatus` | Fines | payment_status | Outstanding fines report and fine validation |
| `IX_Members_Email` | Members | email | Duplicate check on every registration |
| `IX_Members_Status` | Members | status | Membership validity check on every borrow |
| `IX_Members_ExpiryDate` | Members | expiry_date | Membership validity check on every borrow |
| `IX_Copies_Availability` | Copies | availability | Checked on every single borrow transaction |
| `IX_Copies_BookID` | Copies | book_id | Every join from Books to Copies uses this |

---

## 📁 Repository Structure

```
library-database/
│
├── schema/
│   └── create_tables.sql        # DDL for all 9 tables
│
├── data/
│   └── library_population.sql   # Seed data — 100 members, 30 books, ~400 borrowings
│
├── functions/
│   └── functions.sql            # fn_IsMembershipValid, fn_DaysOverdue, fn_MemberOutstandingFines
│
├── procedures/
│   ├── transactions.sql         # usp_BorrowBook, usp_ReturnBook, usp_RegisterMember
│   └── reports.sql              # All four report procedures
│
├── views/
│   └── views.sql                # All five views
│
├── indexes/
│   └── indexes.sql              # All 11 indexes
│
└── README.md
```

---

## 🧠 Key Design Decisions

**Copies as a separate table** — A book title and a physical copy are two different things. Separating them allows accurate availability tracking per copy while keeping catalogue information clean and non-redundant.

**BookAuthors junction table** — Books and authors have a many-to-many relationship. A junction table handles this cleanly without duplicating data or limiting books to a single author.

**Nullable return_date** — A NULL `return_date` in Borrowings is meaningful data — it means the book is still out. This allows active borrowings to be identified without needing a separate status column.

**Functions for reusable logic** — Membership validation and fine calculation appear across multiple procedures and views. Encapsulating them in functions ensures consistency and makes future changes a single-point update.

**Selective indexing** — Every index speeds up reads but slows down writes. Indexes were created only where query frequency justifies the overhead, particularly on the high-traffic Borrowings table.

**Procedure vs view classification** — Views serve as always-on windows into current data. Stored procedures handle parameterized, on-demand queries and all data modification with full transaction control and error handling.

---

## 📊 Dataset Summary

| Entity | Count |
|---|---|
| Genres | 5 |
| Authors | 20 |
| Books | 30 |
| Copies | 150 |
| Staff | 8 |
| Members | 100 |
| Borrowings | ~400 |
| Fines | Proportional to overdue returns |

---

*Built with SQL Server. Designed for learning and portfolio purposes.*