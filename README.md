
# Customer Management System

This project provides a set of stored procedures and triggers for managing customer data in an Oracle database. The system allows users to perform various operations such as adding, modifying, deleting, and querying customer information.

## Package: `customer_management`

The `customer_management` package includes the following functionalities:

### Types
- **customer_record**: A record type that represents a customer's details.
  - **code**: Customer code.
  - **name**: Customer's name.
  - **address**: Customer's address.
  - **zipcode**: Customer's zip code.
  - **born_date**: Customer's birth date.
  - **email**: Customer's email address.

### Procedures
- **query_customer_code**: Queries a customer by their customer code.
- **query_customers**: Lists all customers.
- **query_customers_email**: Queries customers by their email.
- **query_customers_cp**: Queries customers by their zip code.
- **addCustomer**: Adds a new customer to the database.
- **deleteCustomer**: Deletes a customer from the database.
- **modCustomer**: Modifies an existing customer's details (address, zip code, birthday, email).

### Functions
- **verificarv_customer**: Validates customer data before inserting or updating.
- **existev_customer**: Checks if a customer already exists in the database.
- **cursorCustomers**: Returns a cursor for all customers ordered by their name.
- **cursorZipcode**: Returns a cursor for customers based on their zip code.
- **cursorCustomersbyemailtype**: Returns a cursor for customers matching a specific email pattern.

### Triggers
- **emailupdatetrigger**: Prevents email updates unless the email is null.
- **birthdayinserttrigger**: Prevents inserting a customer with a future birthday.
- **birthdayupdatetrigger**: Prevents updating a customer's birthday to a future date or a past date that is earlier than the existing one.
- **namemandatory**: Ensures that the customer's name is not null when inserting a record.
- **customernamemodifytrigger**: Prevents modifying the customer's name once set.

## Usage

To use the system, the user can interact with the provided procedures by choosing options such as adding a new customer, modifying an existing customer, or deleting a customer.

Example script to add a new customer:

```sql
customer_management.addCustomer('C001', 'John Doe', '123 Elm St', '12345', '1985-06-15', 'john.doe@example.com');
```

Example script to query customers by their email:

```sql
customer_management.query_customers_email('example.com');
```

## Error Handling

The system uses exception handling for common errors such as invalid customer data, attempts to modify the customer name, or inserting invalid birthdays.

### Common Errors:
- Invalid customer code format
- Invalid email format
- Customer name is null
- Future date for birthday

## Conclusion

This package and its components provide a structured way to manage customer information with validations, error handling, and triggers to ensure data integrity.
