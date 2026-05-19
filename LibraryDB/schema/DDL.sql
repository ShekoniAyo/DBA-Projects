CREATE TABLE Genre (
    genre_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    name VARCHAR(20) NOT NULL
);

CREATE TABLE Books (
    book_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    genre_id INT NOT NULL FOREIGN KEY REFERENCES  [Genre](genre_id),
    ISBN VARCHAR(25) NOT NULL,
);


CREATE TABLE Authors (
    author_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
);

CREATE TABLE BookAuthors (
    book_id INT NOT NULL FOREIGN KEY REFERENCES [Books](book_id),
    author_id INT NOT NULL FOREIGN KEY REFERENCES [Authors](author_id),
    PRIMARY KEY ([book_id], [author_id])
);

CREATE TABLE Copies (
    copy_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    book_id INT NOT NULL FOREIGN KEY REFERENCES [Books](book_id),
    [availability] BIT NOT NULL,
);


CREATE TABLE Members (
    member_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    [address] VARCHAR(50) NOT NULL,
    phone_no VARCHAR(15),
    gender CHAR(2) CHECK (gender IN ('M', 'F')),
    DOB DATE NOT NULL CHECK (DOB <= DATEADD(YEAR, -18, GETDATE())),
    email VARCHAR(50) NOT NULL,
    reg_date DATE NOT NULL,
    [expiry_date] DATE NOT NULL,
    status VARCHAR(10) DEFAULT 'Active' CHECK (status IN ('Active', 'Expired', 'Inactive'))
);

ALTER TABLE Members 
ADD CONSTRAINT UQ_Members_Email UNIQUE (email);

CREATE TABLE Staff (
    staff_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR (20) NOT NULL,
    gender CHAR(2) CHECK (gender IN ('M', 'F')),
    email VARCHAR(50) NOT NULL,
    position VARCHAR(30) NOT NULL,
    hire_date DATE NOT NULL,
);

ALTER TABLE Staff
ADD CONSTRAINT UQ_StaffEmail UNIQUE (email);

CREATE TABLE Borrowings (
    borrow_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    copy_id INT NOT NULL FOREIGN KEY REFERENCES Copies(copy_id),
    member_id INT NOT NULL FOREIGN KEY REFERENCES Members(member_id),
    staff_id INT NOT NULL FOREIGN KEY REFERENCES Staff(staff_id),
    borrow_date DATE NOT NULL CHECK (borrow_date <= GETDATE()),
    date_due DATE NOT NULL,
    return_date DATE NULL
);

CREATE TABLE Fines (
    fine_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY, 
    borrow_id INT NOT NULL FOREIGN KEY REFERENCES Borrowings(borrow_id),
    issue_date DATE NOT NULL,
    amount DECIMAL(7, 2) NOT NULL,
    payment_status VARCHAR(10) DEFAULT 'Not Paid' CHECK (payment_status IN ('Paid', 'Not Paid')),
    payment_date DATE NULL
);