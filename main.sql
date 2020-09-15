create or replace package customer_management as

  type customer_record is record(
  code      customer.customer_code%type,
  name      customer.customer_name%type,
  address   customer.customer_address%type,
  zipcode       customer.customer_cp%type,
  born_date customer.born_date%type,
  email     customer.email%type);
  cliente customer_record;
  
  procedure query_customer_code(codecustomer customer.customer_code%type);
  procedure query_customers;
  procedure query_customers_email(email customer.email%type);
  procedure query_customers_cp(zipcode customer.customer_cp%type);
  
  procedure addCustomer(code varchar2, v_name varchar2, address varchar2, zipcode varchar2, birthday varchar2, email varchar2);
  procedure deleteCustomer(code number);
  procedure modCustomer(code varchar2, newaddress varchar2, newzipcode varchar2, newdate varchar2, newemail varchar2);
  
end customer_management;
/

-- ^**************************************** BODY *********************************************************

create or replace package body customer_management as
  type_customer customer_record; 
  
 function verificarv_customer 
  (code varchar2, name varchar2, address varchar2, zipcode varchar2, email varchar2)
  return boolean
  is
    esReal boolean := false;
	code_exp exception;
	name_exc exception;
	address_exc exception;
	zipcode_exc exception;
	email_exc exception;
  begin 
  
    
    if length(code) > 9 or length(code) is null then 
	  raise code_exp;
    end if;
  
    if length(name) > 30 or length(name) is null then
	raise name_exc;
    end if;
    
    if length(address) > 30 then  
      raise address_exc;
    end if;
    
    if length(zipcode) > 5 then 
      raise zipcode_exc;
    end if;
 
    if length(email)>30 then 
      raise email_exc;
    end if;
	return esReal;
	exception
	when code_exp then
	dbms_output.put_line ('error, customer_code must be 9 characters and 1 minimum');
	esReal := true;
	return esReal;
	when name_exc then
	dbms_output.put_line('the customer name must be a maximum of 30 characters and a minimum of 1');
	esReal := true;
	return esReal;
	when address_exc then
	dbms_output.put_line('the customer_address must be maximum 30 characters)');
	esReal := true;
	return esReal;
	when zipcode_exc then
	dbms_output.put_line('the customer_cp must be maximum 5 characters and minimum 1');
	esReal := true;
	return esReal;
	when email_exc then
	dbms_output.put_line('the email must be maximum 30 characters and minimum 1');
	esReal := true;
	return esReal;
	
    
  end verificarv_customer; 		  
  
 
  function existev_customer(code customer.customer_code%type)
  return boolean
  is
	existe boolean := false;
    v_code customer.customer_code%type;
  begin
    select customer_code
    into v_code
    from customer
    where customer_code = code;
	existe := true;
    return existe;
  exception
    when no_data_found then
	  existe := false;
      return existe;
    when others then
      dbms_output.put_line('ERROR' || sqlcode || ', ' || sqlerrm);
  end existev_customer;
  
  procedure addCustomer(code varchar2, v_name varchar2, address varchar2, zipcode varchar2, birthday varchar2, email varchar2)
  is 
  v_customer404 exception;
  codeRepetido exception;
  begin
    if verificarv_customer(code,v_name, address, zipcode, email) then
       raise v_customer404;
    else 
      if existev_customer(code) then
        raise codeRepetido;
      else 
        insert into customer
        values (code, v_name, address, zipcode, birthday, email);
        if sql%found then
		  dbms_output.put_line('*******************************');
          dbms_output.put_line('ADDED CUSTOMER');
          dbms_output.put_line('Code: ' || code);
          dbms_output.put_line('Name: ' || v_name);
          dbms_output.put_line('Address: ' || address);
          dbms_output.put_line('Zip Code: ' || zipcode);
          dbms_output.put_line('Birthday: ' || birthday);
          dbms_output.put_line('email: ' || email);
          dbms_output.put_line('*****************************');
		  commit;
        else
          dbms_output.put_line('ERROR INSERTING THE CUSTOMER, A ROLLBACK WILL BE PERFORMED');
		  rollback;
        end if;
      end if;
    end if;
	exception
	when v_customer404 then
	dbms_output.put_line('IT WAS AN ERROR INSERTING DATA OF THE CUSTOMER. PLEASE CHECK IT AGAIN ');
	when codeRepetido then
	dbms_output.put_line('ERROR, THE CUSTOMER CODE ALREADY EXISTS');
  end addCustomer;
  
  procedure deleteCustomer(code number)
  is 
  begin
   delete from customer where customer_code = code;
   if sql%found then
    
    dbms_output.put_line('the customer: ' || code || ' has been deleted from the database');
   else 
    dbms_output.put_line('There was an error deleting the customer: ' || code );
   end if;
  end;
  
  procedure modCustomer(code varchar2, newAddress varchar2, newZipcode varchar2, newDate varchar2, newemail varchar2)
  is
  
  v_email customer.email%type;
  v_date customer.born_date%type;
  v_zipcode customer.customer_cp%type;
  v_address customer.customer_address%type;
  v_customer customer%rowtype;
  
  newemail404 exception;
  newAddress404 exception;
  newDate404 exception;
  newZipcode404 exception;
  wrongBirthdayFormat exception;
  pragma exception_init(wrongBirthdayFormat, -01861);
  invalidDay exception;
  pragma exception_init(invalidDay, -01847);
  invalidMonth exception;
  pragma exception_init(invalidMonth, -01843);
  refuseStrings exception;
  pragma exception_init(refuseStrings, -01858);
 
  begin
  
  select * into v_customer from customer where customer_code = code;
  
  if newemail is null then 
    raise newemail404;
      v_email := v_customer.email;
  else 
    v_email:=newemail;
  end if;
  
  if newAddress is null then 
    raise newAddress404;
      v_address := v_customer.customer_address;
  else 
    v_address:=newAddress;
  end if;
    if newZipcode is null then 
		raise newZipcode404;
      v_zipcode := v_customer.customer_cp;
    else 
      v_zipcode:=newZipcode;
    end if;

    if newDate is null then 
	raise newDate404;
      v_date := v_customer.born_date;
    else 
      v_date:=newDate;
    end if;
  
  update customer
  set customer_address = v_address, customer_cp = v_zipcode ,born_date = v_date, email = v_email
  where customer_code = code;
  
  if sql%found then
    dbms_output.put_line('**********************************************'); 
    dbms_output.put_line( sql%rowcount ||' customers has been updated! '); 
    dbms_output.put_line('New customer code: ' || code);
    dbms_output.put_line('New address: ' || newAddress);
    dbms_output.put_line('New zip code: ' || newZipcode);
    dbms_output.put_line('New email: ' || newemail);
	dbms_output.put_line('**********************************************'); 
  else 
      dbms_output.put_line('error updating the customer '||code||'');
  end if;
  
  exception
	when newDate404 then
	dbms_output.put_line('error! The date introduced is null');
	when newZipcode404 then
	dbms_output.put_line('error! The zip code introduced is null');
	when newAddress404 then
	 dbms_output.put_line('error! The address introduced is null');
	when newemail404 then
	dbms_output.put_line('error! The email introduced is null');
    when no_data_found then
      dbms_output.put_line ('error! there is no data in the table');
    when invalidDay then 
      dbms_output.put_line('error! invalid day'); 
      dbms_output.put_line(sqlerrm);
    when invalidMonth then 
      dbms_output.put_line('error! invalid month'); 
      dbms_output.put_line(sqlerrm);
    when refuseStrings then 
      dbms_output.put_line('error! only numbers allowed, no strings'); 
      dbms_output.put_line(sqlerrm);
    when wrongBirthdayFormat then 
      dbms_output.put_line('error! wrong date format'); 
      dbms_output.put_line(sqlerrm);
    when others then 
      dbms_output.put_line ('error! please try again');
      dbms_output.put_line(sqlerrm); 
  end modCustomer;

  function cursorCustomers 
  return sys_refcursor 
  is
    type ref_cursor is ref cursor;
    cursor_funcion ref_cursor;
  begin
    open cursor_funcion for select customer_code, customer_name, customer_address,customer_cp, born_date, email 
    from customer order by 2;
    return cursor_funcion;
  exception
    when no_data_found then
      dbms_output.put_line('NO DATA WAS FOUND');
    when others then
      dbms_output.put_line('ERROR: '||sqlcode);
  end cursorCustomers;
  
  function cursorZipcode(zipcode customer.customer_cp%type) 
  return sys_refcursor 
  is
 
    type ref_cursor is ref cursor;
    cursor_funcion ref_cursor;
  begin
    open cursor_funcion for select customer_code, customer_name, customer_address,customer_cp, born_date, email 
    from customer where customer_cp = 08940;
    return cursor_funcion;
  exception
    when no_data_found then
      dbms_output.put_line('error: NO DATA WAS FOUND');
    when others then
      dbms_output.put_line('error: '||sqlcode);
  end cursorZipcode;
  
  function cursorCustomersbyemailtype(email customer.email%type) 
  return sys_refcursor
  is 
  type ref_cursor is ref cursor;
    cursor_funcion ref_cursor;
    v_email varchar2(15);
    begin
    v_email := '%'|| email ||'%';
      open cursor_funcion for select customer_code, customer_name, customer_address,customer_cp, born_date, email 
      from customer where upper(email) like upper(v_email);
      return cursor_funcion;
    exception
    when no_data_found then
      dbms_output.put_line('error: NO DATA WAS FOUND');
    when others then
      dbms_output.put_line('error: '||sqlcode);
  end cursorCustomersbyemailtype;
	
  procedure query_customer_code(codecustomer customer.customer_code%type)
  is
    customerRowType customer%rowtype;
  begin
    select * into customerRowType from customer where customer_code = codecustomer;
    dbms_output.put_line('Customer code: '|| customerRowType.customer_code);
    dbms_output.put_line('Name: ' || customerRowType.customer_name);
	dbms_output.put_line('Birthday: '|| customerRowType.born_date);
	dbms_output.put_line('Email: '|| customerRowType.email);
    dbms_output.put_line('Address: '|| customerRowType.customer_address);
    dbms_output.put_line('Zip code: '|| customerRowType.customer_cp);
  exception
    when no_data_found then
      dbms_output.put_line('error: there is no customer with this code '|| codecustomer);
    when others then
      dbms_output.put_line('error: '||sqlcode);
  end query_customer_code;
  
  procedure query_customers
  is
    ref_cursor sys_refcursor;
    v_customer customer_record;
  begin
  ref_cursor := cursorCustomers();
    dbms_output.put_line('Displaying the customer information');
    loop
      fetch ref_cursor into v_customer; exit when ref_cursor%notfound;                                 
        dbms_output.put_line (v_customer.code||v_customer.name||v_customer.address||v_customer.zipcode||floor((sysdate-v_customer.born_date)/365)||v_customer.email);
    end loop;
     dbms_output.put_line('cursor closed');
    exception 
      when others then
        dbms_output.put_line ('error: '||sqlcode);  
  end query_customers;
  
  procedure query_customers_email(email customer.email%type)
  is
    ref_cursor sys_refcursor;
    v_customer customer_record;
  begin
    ref_cursor := cursorCustomersbyemailtype(email);
    dbms_output.put_line('Displaying the customers with the email '||email);
    loop
      fetch ref_cursor into v_customer; exit when ref_cursor%notfound;                                 
       dbms_output.put_line ( v_customer.code || v_customer.name || v_customer.address || v_customer.zipcode || floor((sysdate-v_customer.born_date)/365)  || v_customer.email );
    end loop;
     dbms_output.put_line('cursor closed');
    exception 
      when others then
        dbms_output.put_line ('error: '||sqlcode);  
  end query_customers_email;
  
  procedure query_customers_cp(zipcode customer.customer_cp%type)
  is
    ref_cursor sys_refcursor;
    v_customer customer_record;
  begin
    ref_cursor := cursorZipcode(zipcode);
    dbms_output.put_line('Displaying the customers with the zipcode '||zipcode);
    loop
      fetch ref_cursor into v_customer; exit when ref_cursor%notfound;                                 
        dbms_output.put_line ( v_customer.code || v_customer.name || v_customer.address || v_customer.zipcode || floor((sysdate-v_customer.born_date)/365)  || v_customer.email );
    end loop;
     dbms_output.put_line('cursor closed');
    exception 
      when others then
        dbms_output.put_line ('error: '||sqlcode);  
  end query_customers_cp;
end customer_management;
/

-- ************************ SCRIPTS DE INSERCION BORRADO Y ACTUALIZACION *********************************************


set serveroutput on;
set echo off
set verify off

  accept opcio    char prompt 'choose an option: 1 = add customer // 2 - modify customer 3 = delete customer';
  accept code    char prompt 'introduce the customers code'
  accept name    char prompt 'introduce the customer name'
  accept address  char prompt 'introduce the customers address '
  accept zipcode char prompt 'introduce the customers zipcode'
  accept birthday  char prompt 'introduce the customers birthday'
  accept email     char prompt 'introduce the customers email address'
  
declare

  refusestrings exception;
  pragma exception_init(refusestrings, -06502); 
  wrongformatmonth exception;
  pragma exception_init(wrongformatmonth, -01843); 
  wrongformatdays exception;
  pragma exception_init(wrongformatdays, -01861);
  wrongformatyears exception;
  pragma exception_init(wrongformatyears, -01830);
  wrongformatdate exception;
  pragma exception_init(wrongformatdate, -01858);
  secondcustomer exception;
  pragma exception_init(secondcustomer, -02292);

  v_option    varchar2(75):=  '&opcio';
  v_code    varchar2(75) := '&code';
  v_name    varchar2(75) := '&name';
  v_address  varchar2(75) := '&address';
  v_zipcode varchar2(75) := '&zipcode';
  v_birthday  varchar2(75) := '&birthday';
  v_email     varchar2(75) := '&email';
 
begin
  case v_option
    when 1 then
	dbms_output.put_line(' ************* option add customer selected ***************** ');
	customer_management.addcustomer (v_code, v_name, v_address, v_zipcode, v_birthday, v_email);
    when 2 then
	dbms_output.put_line(' ************* option modify customer selected ***************** ');
    customer_management.modcustomer(v_code, v_address, v_zipcode, v_birthday, v_email);
    when 3 then
	dbms_output.put_line(' ************* option delete customer selected ***************** ');
	customer_management.deletecustomer(v_code);
    else
      dbms_output.put_line('wrong option, please try again');
  end case;
  
exception
  when refusestrings then 
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('error! only numbers allowed, no strings'); 
  when wrongformatmonth then 
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('error! wrong format in months');   
  when wrongformatdate then   
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('error! wrong format');   
  when wrongformatdays then 
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('error! wrong format in days');
  when wrongformatyears then 
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('error! wrong format in years'); 
  when secondcustomer then 
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('error! the customer you are trying to delete exists in other tables');    
  when others then                
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('error! please try again');
end;
/


-- **************************************************************** SCRIPTS DE CONSULTAS **********************************************************

accept opcio  char prompt 'choose option and fill ¡¡only!! the mandatory fields: 1 - display all customers 2 - 
		display customers by their codes  3 - display customers by their emails  4 - display customers by their zipcodes.';
  accept code    char prompt 'introduce the customers code'
  accept zipcode char prompt 'introduce the customers zip code'
  accept email     char prompt 'introduce the customers email'
declare
   
  wrongformatdays exception;
  pragma exception_init(wrongformatdays, -01861);
  wrongformatmonth exception;
  pragma exception_init(wrongformatmonth, -01843); 
  wrongformatyear exception;
  pragma exception_init(wrongformatyear, -01830);
  refusestringinnumbers exception;
  pragma exception_init(refusestringinnumbers, -06502); 
  wrongformatstring exception;
  pragma exception_init(wrongformatstring, -01858);
  secondcustomer exception;
  pragma exception_init(secondcustomer, -02292);
  v_option    varchar2(75):=  '&opcio';
  v_code    varchar2(75) := '&code';
  v_zipcode varchar2(75) := '&zipcode';
  v_email     varchar2(75) := '&email';
  
begin
  case v_option
    when 1 then
		customer_management.query_customers;   
    when 2 then
		customer_management.query_customer_code(v_code);
    when 3 then
		customer_management.query_customers_email(v_email);
    when 4 then
		customer_management.query_customers_cp(v_zipcode);
    else
		dbms_output.put_line('ERROR invalid option, please try again');
  end case;
 
 
exception
	when wrongformatdays then 
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('error! wrong format in days');
	  
	when wrongformatmonth then 
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('error! wrong format in months');   
	  
	when wrongformatyear then 
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('error! wrong format in years'); 
	  
	when refusestringinnumbers then 
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('error! only numbers allowed, no strings'); 
	  
   when wrongformatstring then   
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('error! only numbers allowed, no strings');   
	  
	when secondcustomer then 
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('error! the customer you are trying to delete exists in other tables');    
	  
	when others then                
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('error! please try again');
end;
/

select * from customer;



-- *************************************************  TRIGGERS *****************************************
create or replace trigger emailupdatetrigger
before update of email on customer
for each row
begin
    if (:old.email not like :new.email) and (:old.email) is not null  then
        raise_application_error(-20006,'trigger pulled!: the customer email can only be updated when it is null');
    end if;
end; 
/

create or replace trigger birthdayinserttrigger
before insert on customer
for each row
begin
    if :new.born_date > sysdate then
        raise_application_error(-20007,'¡trigger pulled!: the birthday of the customer cannot be greater than the current date');
    end if;
end;
/

create or replace trigger birthdayupdatetrigger
before update of born_date on customer
for each row
begin
    if :new.born_date > sysdate then
        raise_application_error(-20008,'¡trigger pulled!: the birthday of the customer cannot be greater than the current date');
    end if;
    if :new.born_date < :old.born_date then
        raise_application_error(-20009,'¡trigger pulled! the birthday of the customer cannot be less than the date that is already in the system');
    end if;
end;
/

create or replace trigger namemandatory
before insert on customer
for each row
begin
    if :new.customer_name is null then
        raise_application_error(-20010,'¡trigger pulled!: customers name cannot be null');
    end if;
end;
/

create or replace trigger customernamemodifytrigger
before update on customer
for each row
begin
    if upper(:old.customer_name) not like upper(:new.customer_name) then
        raise_application_error(-20011,'¡trigger pulled! the name of the customer cannot be modified');
    end if;
end;
/