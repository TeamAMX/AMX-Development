for getting the currentstate in the amxpartspecificationdata
Initially we need to add column called currentstate to the table amxpartspecificationdata.

ALTER TABLE amxpartspecificationdata ADD COLUMN currentstate varchar(15);
