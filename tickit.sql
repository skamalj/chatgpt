CREATE TABLE redshift.users (
  userid INT64 NOT NULL,
  username STRING,
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

CREATE TABLE redshift.venue (
  venueid INT64 NOT NULL,
  venuename STRING,
  venuecity STRING,
  venuestate STRING,
  venueseats INT64
);

CREATE TABLE redshift.category (
  catid INT64 NOT NULL,
  catgroup STRING,
  catname STRING,
  catdesc STRING
);

CREATE TABLE redshift.date (
  dateid INT64 NOT NULL,
  caldate DATE NOT NULL,
  day STRING NOT NULL,
  week INT64 NOT NULL,
  month STRING NOT NULL,
  qtr STRING NOT NULL,
  year INT64 NOT NULL,
  holiday BOOL
);

CREATE TABLE redshift.event (
  eventid INT64 NOT NULL,
  venueid INT64 NOT NULL,
  catid INT64 NOT NULL,
  dateid INT64 NOT NULL,
  eventname STRING,
  starttime TIMESTAMP
);

CREATE TABLE redshift.listing (
  listid INT64 NOT NULL,
  sellerid INT64 NOT NULL,
  eventid INT64 NOT NULL,
  dateid INT64 NOT NULL,
  numtickets INT64 NOT NULL,
  priceperticket NUMERIC(8,2),
  totalprice NUMERIC(8,2),
  listtime TIMESTAMP
);

CREATE TABLE redshift.sales (
  salesid INT64 NOT NULL,
  listid INT64 NOT NULL,
  sellerid INT64 NOT NULL,
  buyerid INT64 NOT NULL,
  eventid INT64 NOT NULL,
  dateid INT64 NOT NULL,
  qtysold INT64 NOT NULL,
  pricepaid NUMERIC(8,2),
  commission FLOAT64,
  saletime TIMESTAMP
);
