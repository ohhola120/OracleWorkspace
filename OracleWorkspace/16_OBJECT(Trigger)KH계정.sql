/*
    <트리거>
    내가 트리거로 지정한 테이블에 INSERT , UPDARE , DELETE등의 DML문에 의한 변경하랑이 생길때
    자동으로 매번 실행할 내용을 미리 정의해 둘 수 있는 객체

    EX)
    회원탈퇴시 기존의 회원테이블에 데이터를 DELETE한 후 곧바로 탈퇴한 회원들만 따로 보관하는 테이블에 자동 INSERT시키고자 할떄
    
    입출고에 대한 데이터가 기록될떄마다 해당 상품에 대한 재고수량을 매번 수정해야 될때
    
    * 트리거 종류
    SQL문의 시행시기에 따른 분류
     > BEFORE TRIGGER : 내가 지정한 테이블에 이벤트(DML)가 발생되기 "전"트리거가 먼저 실행
     
     > AFTER TRIGGER : 내가 지정한 테이블에 이번트가 발생된 후에 실행되는 트리거
     
     SQL문에 의해 영향을 받는 "행"에 따른 분류
     >STATEMENT TRIGGER(문장트리거) : 이벤트가 발생한 SQL문에 대해 딱 한번만 실행되는 트리거
     
     > ROW TRIGGER (행 트리거): 이벤트가 발생한 SQL문 실행시 매번 실행되는 트리거. (FOR EACH ROW옵션기술 필요)
     
            > : OLD - BEFORE UPDATE(수정전자료) , BEFORE DELETE(삭제전 자료)
            > : NEW - AFTER INSERT(추가된 자료), AFTER UPDATE(수정후 자료)
    [표현법]
    CREATE OR REPLACE TRIGGER 트리거명
    BEFORE|AFTER INSERT|UPDATE|DELETE ON 테이블명
    [FOR EACH ROW]
    PL/SQL;
*/
--EMPLOYEE 테이블에 새로운 행이 INSERT될때 마다 자동으로 메세지가 출력되는 트리거 정의.
CREATE OR REPLACE TRIGGER TRG_01
AFTER INSERT ON EMPLOYEE
BEGIN
DBMS_OUTPUT.PUT_LINE('신입사원님 환영합니다');
END;
/

ALTER TABLE EMPLOYEE DROP CONSTRAINT EMPLOYEE_PK;

INSERT INTO EMPLOYEE(EMP_ID,EMP_NAME,EMP_NO,JOB_CODE,SAL_LEVEL)
SELECT * FROM (
SELECT 107 , '두진','123456-1234567', 'J1','S1' FROM DUAL
UNION ALL
SELECT 108 , '두진','123456-1234567', 'J1','S1' FROM DUAL
UNION ALL
SELECT 109 , '두진','123456-1234567', 'J1','S1' FROM DUAL
);

INSERT INTO EMPLOYEE(EMP_ID,EMP_NAME,EMP_NO,JOB_CODE,SAL_LEVEL)
VALUES(100,'두진','123456-1234567','J1','S1');

---------------------------------------------------------
--상품 입출고 관련 예시
--> 필요한 테이블, 시퀀스,테이터 생성

--1. 상품에 대한 데이터를 저장할 테이블(TB_PRODUCT)
CREATE TABLE TB_PRODUCT(
PCODE NUMBER PRIMARY KEY,
PNAME VARCHAR2(30) NOT NULL,
BRAND VARCHAR2(30) NOT NULL,
PRICE NUMBER,
STOCK NUMBER DEFAULT 0
);

--상품번호 시퀀스 SEQ_PCODE
CREATE SEQUENCE SEQ_PCODE
START WITH 200
INCREMENT BY 5;

INSERT INTO TB_PRODUCT VALUES (SEQ_PCODE.NEXTVAL, '갤럭시Z플립4','삼성',1350000,DEFAULT);
INSERT INTO TB_PRODUCT VALUES (SEQ_PCODE.NEXTVAL, '갤럭시S11','삼성',1000000,10);
INSERT INTO TB_PRODUCT VALUES (SEQ_PCODE.NEXTVAL, '아이폰14','애플',1500000,20);
SELECT * FROM TB_PRODUCT;
COMMIT;

--2상품 입출고 종보를 보관하느 테이블(TB_PRODETAIL)
-- 어떤 상품이 어떤 날짜에 몇개가 입고 혹은 출고가 되었는지를 기록하는 테이블.
CREATE TABLE TB_PRODETAIL(
DCODE NUMBER PRIMARY KEY , --이력번호
PCODE NUMBER REFERENCES TB_PRODUCT(PCODE), -- 상품번호
PDATE DATE NOT NULL, --입출고일
AMOUNT NUMBER NOT NULL, -- 입출고 수량
STATUS CHAR(6) CHECK(STATUS IN('입고','출고'))-- 상태(입,출고)
);
--이력번호를 저장할 시퀀스 생성.
CREATE SEQUENCE SEQ_DCODE;

--
INSERT INTO TB_PRODETAIL
VALUES (SEQ_DCODE.NEXTVAL , 200 , SYSDATE, 10 , '입고');

--200번상풍의 재고수량 10개 증가
UPDATE TB_PRODUCT SET
STOCK = STOCK + 10
WHERE PCODE = 200;

SELECT * FROM TB_PRODUCT;

COMMIT;

-- TB_PRODETAIL테이블에 INSERT 이벤트가 발생하면
--TB_PRODUCT테이블에 매번 자동으로 재고수량을 UPDATE되게끔 트리거를 정의
/*
    - 상품이 입고된 경우 -> 해당상품의 재고수량 + 업데이트
    - 상품이 출고된 경우 -> 해당상품의 재고수량 - 업데이트
*/
CREATE OR REPLACE TRIGGER TRG_02
AFTER INSERT ON TB_PRODETAIL
FOR EACH ROW
BEGIN
    -- 상품이 입고된 경우
    -- :OLD , :NEW
   IF :NEW.STATUS = '입고' THEN
       UPDATE TB_PRODUCT SET
       STOCK = STOCK + :NEW.AMOUNT
       WHERE PCODE = :NEW.PCODE;
   ELSE
        -- 상품이 출고된 경우
       UPDATE TB_PRODUCT SET
       STOCK = STOCK - :NEW.AMOUNT
       WHERE PCODE = :NEW.PCODE;
   END IF;
   -- COMMIT; 안됨
END;
/

SELECT * FROM TB_PRODUCT;

SELECT * FROM TB_PRODETAIL;

-- 210번 상품 오늘날짜로 7개 출고
INSERT INTO TB_PRODETAIL
VALUES (SEQ_DCODE.NEXTVAL, 210, SYSDATE, 7, '출고');

-- 200번 상품 오늘 날짜로 100개 입고
INSERT INTO TB_PRODETAIL
VALUES (SEQ_DCODE.NEXTVAL, 200, SYSDATE, 100, '입고');

/*
     트리거 장점
     1. 데이터 추가, 수정, 삭제 자동으로 데이터 관리를 해줌으로써 데이터 무결성 보장 가능.
     2. 데이터베이스 관리의 자동화가 가능해진다.
    
     트리거 단점
     1. 빈번한 추가, 수정, 삭제시 각 ROW의 삽입, 추가, 삭제가 함께 실행되므로 성능상 좋지 못하다.
     2. 관리적 측면에서 형상관리가 불가능하기 때문에 관리가 힘듬.
     3. 트리거가 하나 데이터베이스에 여러개가 존재하는 경우 각 트리거가 서로 어떤 영향을 끼치는지 파악하기가 힘듬.
*/

















































