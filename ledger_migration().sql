-- Function: public.ledger_migration()

-- DROP FUNCTION public.ledger_migration();

CREATE OR REPLACE FUNCTION public.ledger_migration()
  RETURNS boolean AS
$BODY$
DECLARE
	loan_sl_no_ integer;
	r record;
	
	loan_mast loanmast;
	loan_masts loanmast_[];

	acctnos character varying[];
	acctno_ character varying;
	rep_loanmast_id_ character varying;
	loanmast_id_ character varying;
	stmt_id_ character varying;
	sub_acctno character varying;

	stmt_data RECORD;

BEGIN

acctnos := (SELECT ARRAY(SELECT acctno FROM loan_class));

/*

RAISE NOTICE '------------------------------Start of loan_sl Migration---------------------------';

FOREACH acctno_ IN ARRAY acctnos LOOP

		--acctno := (SELECT concat('LN',replace(acctno,'-',''),'_',_loan_mast.loancode, loan_mast.loanser,'_',_loan_mast.date_grntd) FROM loanmast_ WHERE closed='F');

		--acctno_ := (concat('LN',replace(acctno,'-',''),'',_loan_mast.loancode, loan_mast.loanser,'',_loan_mast.date_grntd));
		rep_loanmast_id_ := (SELECT REPLACE(SUBSTRING(acctno_, 3, 10), '_', ''));
		loanmast_id_ := (SELECT CONCAT(SUBSTRING(rep_loanmast_id_, 1, 2), '-', SUBSTRING(rep_loanmast_id_, 3)):: character varying);
		
		RAISE NOTICE 'acctno: (%)', acctno_;
		RAISE NOTICE 'id_ :  (%)', loanmast_id_;
		RAISE NOTICE 'sub_acctno :  (%)', sub_acctno;
			
		insert into loan_sl (acctno,amount,balance,post_date,trans_no)
		select acctno_, replace(sl.audit_ttl,' ','')::numeric,replace(sl.balance,' ','')::numeric,sl.trans_date::date,sl.trans_no::integer from loan_sl_ sl
		WHERE  SUBSTRING(loanmast_id_, 0, 9) in (sl.acctno ) AND  SUBSTRING(loanmast_id_, 9, 1) in ( sl.loancode) AND  SUBSTRING(loanmast_id_, 10, 1) in ( sl.loanser);

END LOOP;
*/


/*
RAISE NOTICE '------------------------------End of loan_sl Migration----------------------------';

		 FOR i IN 1..25 LOOP
				RAISE NOTICE '-----------------------------------------------------------------------------------';
		  END LOOP;
		  
RAISE NOTICE '------------------------------Start of loan_sldf Migration------------------------';

	select * FROM loan_sl LIMIT 1

	SELECT * FROM sl_df_  WHERE trans_no = '2837558'

	SELECT * FROM loan_sl_ LIMIT 1

	SELECT 
	
	insert into loan_sldf(loan_sl_no, amount, trans_code, dtl_no, entry_type)
	select (select loan_sl_no  from loan_sl where loan_sl.trans_no=sl_df_.trans_no::integer)
	,amount::numeric,trans_type,detail_no,
	CASE substring(trans_type,1,1) 
		WHEN '0' THEN '0'
		WHEN '1' THEN '1'
		ELSE null::integer
	END::integer 
	from sl_df_;


RAISE NOTICE '------------------------------End of loan_sldf Migration----------------------------';

		 FOR i IN 1..25 LOOP
				RAISE NOTICE '-----------------------------------------------------------------------------------';
		  END LOOP;
*/
		  
RAISE NOTICE '------------------------------Start of loan_statement Migration------------------------';



FOREACH acctno_ IN ARRAY acctnos LOOP
		FOR r IN (SELECT acctno, loancode, loanser FROM stmt_)
		rep_loanmast_id_ := (SELECT REPLACE(SUBSTRING(acctno_, 3, 10), '_', ''));
		loanmast_id_ := CONCAT(r.acctno,r.loancode,r.loanser):: character varying);
	

		RAISE NOTICE 'acctno: (%)', acctno_;
		RAISE NOTICE 'id_ :  (%)', loanmast_id_;
		

	insert into loan_statement (
	acctno, statement_date, principal_due, interest_due, 
	fines_due,  principal_paid, interest_paid, fines_paid, 
	previous_balance, current_balance)       
	       
	SELECT acctno_,
	stmt_date::date, 
	
	CASE prin_due WHEN '            ' THEN 0.00::numeric
	ELSE prin_due::numeric
	END::numeric, 
	
	CASE int_due WHEN '            ' THEN 0.00::numeric
	ELSE int_due::numeric
	END::numeric, 
	
	CASE fines_due WHEN '            ' THEN 0.00::numeric
	ELSE fines_due::numeric
	END::numeric,
	
	CASE prin_pd WHEN '            ' THEN 0.00::numeric
	ELSE prin_pd::numeric
	END::numeric, 
	
	CASE int_pd WHEN '            ' THEN 0.00::numeric
	ELSE int_pd::numeric
	END::numeric, 
	
	CASE fines_pd WHEN '            ' THEN 0.00::numeric
	ELSE fines_pd::numeric
	END::numeric, 
	
	CASE prev_bal WHEN '            ' THEN 0.00::numeric
	ELSE prev_bal::numeric
	END::numeric, 
	
	CASE pres_bal WHEN '            ' THEN 0.00::numeric
	ELSE pres_bal::numeric
	END::numeric
	FROM stmt_;

END LOOP;

RAISE NOTICE '------------------------------End of loan_statement Migration----------------------------';

		 FOR i IN 1..25 LOOP
				RAISE NOTICE '-------------------------------------END-------------------------------------------';
		  END LOOP;

		  
RETURN true;
		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.ledger_migration()
  OWNER TO postgres;

  SELECT ledger_migration()

