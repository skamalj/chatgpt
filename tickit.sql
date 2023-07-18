CREATE TABLE `gcdeveloper.tickit.category`
  (
    catid INT64 NOT NULL OPTIONS(description="Primary key, a unique ID value for each row. Each row represents a specific type of event for which tickets are bought and sold."),
    catgroup STRING OPTIONS(description="Descriptive name for a group of events, such as Shows and Sports"),
    catname STRING OPTIONS(description="Short descriptive name for a type of event within a group, such as Opera and Musicals."),
    catdesc STRING OPTIONS(description="Longer descriptive name for the type of event, such as Musical theatre.")
  );
  CREATE TABLE `gcdeveloper.tickit.users`
  (
    userid INT64 NOT NULL OPTIONS(description="Primary key, a unique ID value for each row. Each row represents a registered user (a buyer or seller or both) who has listed or bought tickets for at least one event."),
    username STRING OPTIONS(description="An 8-character alphanumeric username, such as PGL08LJI."),
    firstname STRING,
    lastname STRING,
    city STRING,
    state STRING,
    email STRING,
    phone STRING,
    likesports BOOL,
    liketheatre BOOL,
    likeconcerts BOOL,
    likejazz BOOL,
    likeclassical BOOL,
    likeopera BOOL,
    likerock BOOL,
    likevegas BOOL,
    likebroadway BOOL,
    likemusicals BOOL
  );
  CREATE TABLE `gcdeveloper.tickit.venue`
  (
    venueid INT64 NOT NULL OPTIONS(description="Primary key, a unique ID value for each row. Each row represents a specific venue where events take place."),
    venuename STRING OPTIONS(description="Exact name of the venue, such as Cleveland Browns Stadium."),
    venuecity STRING OPTIONS(description="City name, such as Cleveland."),
    venuestate STRING OPTIONS(description="Two-letter state or province abbreviation (United States and Canada), such as OH."),
    venueseats INT64 OPTIONS(description="Maximum number of seats available at the venue, if known, such as 73200. For demonstration purposes, this column contains some null values and zeroes.")
  );
  CREATE TABLE `gcdeveloper.tickit.sales`
  (
    salesid INT64 NOT NULL OPTIONS(description="Primary key, a unique ID value for each row. Each row represents a sale of one or more tickets for a specific event, as offered in a specific listing."),
    listid INT64 NOT NULL OPTIONS(description="Foreign-key reference to the LISTING table."),
    sellerid INT64 NOT NULL OPTIONS(description="Foreign-key the user who sold the tickets)."),
    buyerid INT64 NOT NULL OPTIONS(description="Foreign-key reference to the USERS table (the user who bought the tickets)."),
    eventid INT64 NOT NULL OPTIONS(description="Foreign-key reference to the EVENT table."),
    dateid INT64 NOT NULL OPTIONS(description="Foreign-key reference to the DATE table."),
    qtysold INT64 NOT NULL OPTIONS(description="The number of tickets that were sold, from 1 to 8. (A maximum of 8 tickets can be sold in a single transaction.)"),
    pricepaid INT64 OPTIONS(description="The total price paid for the tickets, such as 75.00 or 488.00. The individual price of a ticket is PRICEPAID/QTYSOLD."),
    commission FLOAT64 OPTIONS(description="The 15% commission that the business collects from the sale, such as 11.25 or 73.20. The seller receives 85% of the PRICEPAID value."),
    saletime TIMESTAMP OPTIONS(description="The full date and time when the sale was completed, such as 2008-05-24 06:21:47.")
  );
  CREATE TABLE `gcdeveloper.tickit.event`
  (
    eventid INT64 NOT NULL OPTIONS(description="Primary key, a unique ID value for each row. Each row represents a separate event that takes place at a specific venue at a specific time."),
    venueid INT64 NOT NULL OPTIONS(description="Foreign-key reference to the VENUE table."),
    catid INT64 NOT NULL OPTIONS(description="Foreign-key reference to the CATEGORY table."),
    dateid INT64 NOT NULL OPTIONS(description="Foreign-key reference to the DATE table."),
    eventname STRING OPTIONS(description="Name of the event, such as Hamlet or La Traviata."),
    starttime TIMESTAMP OPTIONS(description="Full date and start time for the event, such as 2008-10-10 19:30:00.")
  );
  CREATE TABLE `gcdeveloper.tickit.date`
  (
    dateid INT64 NOT NULL OPTIONS(description="Primary key, a unique ID value for each row. Each row represents a day in the calendar year."),
    caldate DATE NOT NULL OPTIONS(description="Calendar date, such as 2008-06-24."),
    day STRING NOT NULL OPTIONS(description="Day of week (short form), such as SA."),
    week INT64 NOT NULL OPTIONS(description="Week number, such as 26."),
    month STRING NOT NULL OPTIONS(description="Month name (short form), such as JUN."),
    qtr STRING NOT NULL OPTIONS(description="Quarter number (1 through 4)."),
    year INT64 NOT NULL OPTIONS(description="Four-digit year (2008)."),
    holiday BOOL OPTIONS(description="Flag that denotes whether the day is a public holiday (U.S.).")
  );
  CREATE TABLE `gcdeveloper.tickit.listing`
  (
    listid INT64 NOT NULL OPTIONS(description="Primary key, a unique ID value for each row. Each row represents a listing of a batch of tickets for a specific event."),
    sellerid INT64 NOT NULL OPTIONS(description="Foreign-key reference to the USERS table, identifying the user who is selling the tickets."),
    eventid INT64 NOT NULL OPTIONS(description="Foreign-key reference to the EVENT table."),
    dateid INT64 NOT NULL OPTIONS(description="Foreign-key reference to the DATE table."),
    numtickets INT64 NOT NULL OPTIONS(description="The number of tickets available for sale, such as 2 or 20."),
    priceperticket NUMERIC(8, 2) OPTIONS(description="The fixed price of an individual ticket, such as 27.00 or 206.00."),
    totalprice NUMERIC(8, 2) OPTIONS(description="the total price for this listing (NUMTICKETS*PRICEPERTICKET)."),
    listtime TIMESTAMP OPTIONS(description="The full date and time when the listing was posted, such as 2008-03-18 07:19:35.")
  );