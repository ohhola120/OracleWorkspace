/*
    * TCL(TRANSACTION CONTROL LANGUAGE)
    트랜잭션을 제어하는 언어.
    
     * 트랜잭션? 
     - 데이터베이스 논리적 작업단위
     
     - DBMS는 데이터의 변경사항들(DML)들을 하나의 트랜잭션으로 묶어서 관리하다가, TCL문에 의해 실제 데이터베이스에
       반영되거나 취소 처리 된다. (ALL OR NOTING)
       
     - COMMIT(확정)하기 전까지의 변경사항들(DML)들은 하나의 트랜잭션으로 묶이게됨
     - 트랜잭션의 대상이되는 SQL문들은 : INSERT, UPDATE, DELETE.
     
     * 트랜잭션을 제어하는 명령문들은
      - COMMIT : 하나의 트랜잭션에 담겨있는 변경사항들을 실제 DB에 반영하겠다는 것을 의미
                 실제 DB에 반영시킨후 트랜잭션은 비워짐.
      - ROLLBACK : 하나의 트랜잭션에 담겨있는 변경사항들을 실제 DB에 반영하지 않겠다는 것을 의미(취소처리)
                 => 트랜잭션에 담겨있는 다른 변경사항들을 모두 취소처리한 후, 마지막 COMMIT시점으로 돌아간다.
      - SAVEPOINT 포인트명 : 현재 지점은 임시저장시점으로 정의 해두는것.
      
      - ROLLBACK TO 포인트명 : 전체 변경사항들을 삭제하는게 아니라, 포인트명 지점까지의 트랜잭션만 삭제처리함.
*/

SELECT * FROM EMP_01; -- 75;

-- 사번이 901번인 사원 삭제.
DELETE FROM EMP_01
WHERE EMP_ID = 901;

DELETE FROM EMP_01
WHERE EMP_ID = 900;

SELECT COUNT(*) FROM EMP_01; -- 75;

ROLLBACK;

SELECT COUNT(*) FROM EMP_01; -- 75;

/*
    트랜잭션의 특징들
    1. 트랜잭션들은 하나로 묶어서 처리된다. 모두 COMMIT되거나 모두 ROLLBACK으로 처리됨.
       내부작업 단위는 ROLLBACK 혹은 COMMIT 둘중 하나만 선택 가능하며 더 작은 단위로 쪼개질 수 없다.
       트랜잭션은 원자성(ATOMICITY)의 특징을 가짐.
       원자? 더 이상 쪼개지지 않는 물질의 기본단위
*/

-- 사번이 200인 사원삭제
DELETE FROM EMP_01
WHERE EMP_ID = 200;

-- 사번이 800, 홍길동, 총무부
INSERT INTO EMP_01 VALUES(800, '김두진', '총무부'); 

DELETE FROM DEPARTMNET WHERE DEPT_ID = 'D0';
INSERT INTO DEPARTMENT VALUES('D0', '행정부','L2');

ROLLBACK;

/*
   다른 트랜잭션이 제약조건이 부여된 테이블에 대해서 작업을 완료하지 않은 상태라면(COMMIT, ROLLBACK). 다른트랜잭션이
   해당 테이블에 대해서 중간에 끼어들어서 작업처리 할수 없다. 다른 트랜잭션의 작업이 완료되기까지 대기해야함.
   
   즉, 각각의 트랜잭션은 서로 작업에 영향을 끼치지 못하도록 격리되어있음.
   따라서 트랜잭션은 격리성(고립성) ISOLATIONDML 특징을 가지고있다.
   EX) UPDATE EMPLOYEE SET DEPT_CODE = 'D1' WHERE EMP_NAME = '선동일';
       UPDATE EMPLOYEE SET EMP_NAME = '민동일' WHERE EMP_ID ='200';
   
   여태까지 진행하면서 처리 완료된 결과들은 DBMS에 의해 영구적으로 유지되고 있음.
   한번 처리 완료된 트랜잭션은 DBMS에 의해 영구히 반영되므로 지속성(DURABILITY)의 특징을 가진다.
   
   트랜잭션은 항상 일관된 문제없는 데이터만 보이게끔 처리된다. 
   트랜잭션 처리 완료되기 전에 데이터상에 문제가 없었다면 처리 된 이후에도 문제없는 일관된 데이터만 반환해준다.
   
   트랜잭션은 일관성(CONSISTENCY)의 특징을 가졌다.
   
  ✔ A(ATOMICITY) C(CONSISENCY) I(ISOLATION) D(DURABILITY) : ACID;✔
*/
COMMIT;

SELECT * FROM EMP_01;

--------------------------------------------------------------------------------
-- SAVEPOINT, ROLLBACK TO
-- EMP_01테이블에서 사번이 217, 216, 214번인 사원만 삭제
DELETE FROM EMP_01
WHERE EMP_ID IN (214,216,217);

SELECT COUNT(*) FROM EMP_01; -- 100

SAVEPOINT SP1;

INSERT INTO EMP_01
VALUES(801, '김두진','인사부');

SELECT COUNT(*) FROM EMP_01; -- 101

DELETE FROM EMP_01
WHERE EMP_ID = 218 OR EMP_ID = 219;

SELECT COUNT(*) FROM EMP_01; -- 101

ROLLBACK TO SP1;   

SELECT COUNT(*) FROM EMP_01; -- 100

ROLLBACK;

SELECT COUNT(*) FROM EMP_01; -- 100


CREATE TABLE TEST(
    TEST_ID NUMBER
);

SELECT COUNT(*) FROM EMP_01; -- 100

ROLLBACK;

SELECT COUNT(*) FROM EMP_01; -- 100

/*
     주의사항
     DDL구문들을 실행하는 순간 기존에 트랜잭션에 있던 모든 변경사항들을 실제 DB에 반영(COMMIT)시킨 후에 DDL이 수행됨.
     즉 DDL수행전 변경사항이 있었다면 정확히 픽스하고 DDL을 실행해야한다.
*/














































