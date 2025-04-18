/* 
    * DDL(DATA DEFINITION LANGUAGE) 데이터 정의 언어
    
    오라클에서 제공하는 객체를 새롭게 만들고, 구조를 변경하고, 구조를 삭제 할 수 있는 명령문.
    즉, 구조 자체를 정의하는 언어로 DB관리자, 설계자가 사용
    
    객체란 DATABASE를 이루는 구조물들.
    테이블, 인덱스, 사용자, 함수, 뷰, 시퀀스.....    
*/
/* 
    <CREATE TABLE>
    
    테이블 : 행과 열로 구성되어있는 가장 기본적인 데이터베이스 객체 종류중 하나
            모든 데이터는 테이블을 통해서 저장됨.(즉, 데이터를 조작하고자 한다면 무조건 테이블을 만들어야함)
            
    [표현법]
    CREATE TABLE 테이블명 (
        컬럼명 자료형,
        ...
        ...
    );
    
    <자료형>
    - 문자(CHAR(크기)/VARCHAR2(크기) : 크기 BYTE수로 지정 , 글자길이 CHAR로 지정.
                                     (숫자, 영문자, 특수문자 -> 1BYTE)
                                     (한글 3BYTE)
                                     100 BYTE -> 100BYTE까지 추가하겠다.
                                     100 CHAR -> 100글자까지 추가하겠다.
                    CHAR(크기) : 고정크기(아무리 적은값이 들어와도 공백으로 싹 채워서 할당한 크기를 유지),
                                 2000BYTE,
                                 주로 들어올 값의 글자수가 정해져 있을 경우 사용.
                                 EX) 성별, 주민번호
                    VARCHAR2(크기) : 가변길이(적은 값이 들어온 경우 그 값만큼의 저장공간을 사용),
                                    최대 4000 BYTE,
                                    들어올 값의 글자수가 정해지지 않은 경우 사용
    - 숫자 (NUMBER( 양수자리수 , 실수자리수  )) : 정수/실수 상관없이 NUMBER
    
    - 날짜 (DATE) : 년/월/일/시/분/초 형식으로 시간지정
*/
-- 회원관리 테이블(아이디, 비밀번호, 이름, 생년월일)를 담기위한 MEMBER 테이블
CREATE TABLE MEMBER(
    MEMBER_ID VARCHAR2(20),
    memberPwd VARCHAR2(20),
    memberName VARCHAR2(20),
    BIRTHDAY DATE
);
SELECT * FROM MEMBER;

-- 데이터 딕셔너리(사전) : 다양한 객체들의 정보를 저장하고 있는 시스템 테이블
SELECT * FROM USER_TABLES;
-- USER_TABLES : 현재 사용자 계정이 가지고있는 테이블들의 구조를 확인할 수 있는 데이터 사전

SELECT * FROM USER_TAB_COLUMNS;
-- USER_TAB_COLUMNS : 현재 사용자 계정이 가지고있는 테이블들의 전반적인 구조를 확인할 수 있는 데이터 사전.

/* 
    컬럼에 주석달기(컬럼에 대한 설명)
    
    [표현법]
    COMMENT ON COLUMN 테이블명.컬럼명 IS '주석내용';
*/


COMMENT ON COLUMN MEMBER.MEMBER_ID IS '회원아이디';
COMMENT ON COLUMN MEMBER.MEMBERPWD IS '비밀번호';
COMMENT ON COLUMN MEMBER.MEMBERNAME IS '이름';
COMMENT ON COLUMN MEMBER.BIRTHDAY IS '생년월일';

-- 참고 : INSERT (데이터추가구문) => DML문
INSERT INTO MEMBER VALUES('USER01','PASS01','홍길동','80/10/06');

INSERT INTO MEMBER VALUES('USER02','PASS02','김길동','80/10/06');

INSERT INTO MEMBER VALUES('USER03','PASS03','민길동',SYSDATE);

SELECT * FROM MEMBER;

INSERT INTO MEMBER VALUES(NULL, NULL, '홍길동','80/10/06');
INSERT INTO MEMBER VALUES('USER01','PASS01','홍길동','80/10/06');

/* 
    -- 제약조건 : 테이블을 만들때 지정해주는 방법
    
    <제약조건 CONSTRAINTS>
    - 원하는 데이터값만 유지하기 위해서 특정 "컬럼"단위로 설정하는 제약.(데이터의 무결성 보장을 목적)
    - 제약조건이 부여된 칼럼에 들어올 데이터에 문제가 있는지 없는지 자동으로 검사를 해줌.
    
    - 종류 : NOT NULL, UNIQUE, CHECK, PRIMARY KEY, FOREIGN KEY
    
    - 테이블 만들 때 컬럼에 제약조건을 부여하는 방식 : 컬럼레벨 방식 / 테이블레벨 방식
*/
/* 
    1. NOT NULL 제약조건
       해당 컬럼에는 반드시 값이 존재해야만 할 경우 사용
       -> NULL값이 절대 들어와서는 안되는 컬럼에 부여하는 제약조건
          데이터의 삽입/수정시 NULL값을 허용하지 않도록 제한하는 제약조건
        주의사항 : 컬럼레벨방식으로만 제약조건 부여 가능.
*/

-- NOT NULL 제약조건을 설정한 테이블 만들기
-- 컬럼레벨 방식 : 컬럼명 자료형 제약조건
CREATE TABLE MEM_NOTNULL (
    MEM_NO NUMBER NOT NULL,
    MEM_ID VARCHAR2(20) NOT NULL,
    MEM_PWD VARCHAR2(20) NOT NULL,
    MEM_NAME VARCHAR2(20) NOT NULL,
    GENDER CHAR(3) , 
    PHONE VARCHAR2(15),
    EMAIL VARCHAR2(30)
);

INSERT INTO MEM_NOTNULL VALUES(
    1, 'user01' , 'pass01' , '홍길동', '남', '010-1111-1111', 'aaa@naver.com'
);

SELECT *
FROM MEM_NOTNULL;

INSERT INTO MEM_NOTNULL VALUES(
    2, 'user01' , 'pass01' , '김길동', NULL, '010-1111-1111', 'aaa@naver.com'
);
-- DDL계정에 MEM_NOTNULL 테이블에 MEM_ID, MEM_NO등 NOT NULL 제약 조건이 부여되어있는 컬럼에는 NULL이 들어갈수 없음.

DROP TABLE MEM_NOTNULL;
/* 
    2. UNIQUE 제약조건
        컬럼에 중복값을 제한하는 제약조건.
        삽입 / 수정시 기존에 해당 컬럼값에 중복값이 있는경우 추가나 수정이 되지 않게 제약.
*/
CREATE TABLE MEM_UNIQUE (
    MEM_NO NUMBER NOT NULL UNIQUE,
    MEM_ID VARCHAR2(20) NOT NULL UNIQUE,
    MEM_PWD VARCHAR2(20) NOT NULL,
    MEM_NAME VARCHAR2(20) NOT NULL,
    GENDER CHAR(3) , 
    PHONE VARCHAR2(15),
    EMAIL VARCHAR2(30)
);

DROP TABLE MEM_UNIQUE;

CREATE TABLE MEM_UNIQUE (
    MEM_NO NUMBER NOT NULL UNIQUE,
    MEM_ID VARCHAR2(20) NOT NULL ,
    MEM_PWD VARCHAR2(20) NOT NULL,
    MEM_NAME VARCHAR2(20) NOT NULL,
    GENDER CHAR(3) , 
    PHONE VARCHAR2(15),
    EMAIL VARCHAR2(30),
    
    UNIQUE(MEM_ID) -- 테이블 레벨방식
);

INSERT INTO MEM_UNIQUE 
VALUES(1, 'user01' , 'pass01' , '홍길동', NULL,NULL,NULL);

INSERT INTO MEM_UNIQUE 
VALUES(2, 'user01' , 'pass01' , '홍길동', NULL,NULL,NULL);

SELECT * FROM USER_CONSTRAINTS;

/* 
    * 제약조건 부여시 제약조건의 이름도 함께 지정하는 방법.
    -> 컬럼레벨방식
    컬럼명 자료형 제약조건1 제약조건2
    컬럼명 자료형 CONSTRAINT 제약조건명 제약조건 
    
    > 테이블레벨방식
    ....
    CONSTRAINT 제약조건명 제약조건(컬럼명)
*/
DROP TABLE MEM_UNIQUE;

CREATE TABLE MEM_UNIQUE (
    MEM_NO NUMBER NOT NULL CONSTRAINT MEM_UNIQUE_UQ_MEM_NO UNIQUE,
    MEM_ID VARCHAR2(20) NOT NULL ,
    MEM_PWD VARCHAR2(20) NOT NULL,
    MEM_NAME VARCHAR2(20) NOT NULL,
    GENDER CHAR(3) , 
    PHONE VARCHAR2(15),
    EMAIL VARCHAR2(30),
    
   CONSTRAINT MEM_UNIQUE_UQ_MEM_ID UNIQUE(MEM_ID)
);

INSERT INTO MEM_UNIQUE 
VALUES(1, 'user01' , 'pass01' , '홍길동', NULL,NULL,NULL);

INSERT INTO MEM_UNIQUE 
VALUES(1, 'user01' , 'pass01' , '홍길동', NULL,NULL,NULL);

/* 
    3. CHECK 제약조건
       컬럼에 기록될 수 있는 값에 대한 조건을 설정
       EX) 성별에는 '남'혹은 '여'만 들어오게끔 할때 사용
       
       [표현식]
       CHECK(조건식)
*/

DROP TABLE MEM_UNIQUE;

CREATE TABLE MEM_CHECK (
    MEM_NO NUMBER NOT NULL CONSTRAINT MEM_UNIQUE_UQ_MEM_NO UNIQUE,
    MEM_ID VARCHAR2(20) NOT NULL ,
    MEM_PWD VARCHAR2(20) NOT NULL,
    MEM_NAME VARCHAR2(20) NOT NULL,
    GENDER CHAR(3) CHECK(GENDER IN ('남','여') ) , 
    PHONE VARCHAR2(15),
    EMAIL VARCHAR2(30),
    
   CONSTRAINT MEM_UNIQUE_UQ_MEM_ID UNIQUE(MEM_ID)
);

INSERT INTO MEM_CHECK 
VALUES(1, 'user01' , 'pass01' , '홍길동', NULL,NULL,NULL);
-- NOT NULL 제약조건을 추가해야 NULL값 삽입을 방지할 수 있음.

INSERT INTO MEM_CHECK 
VALUES(2, 'user02' , 'pass01' , '홍길동', '남' ,NULL,NULL);
-- 정상

INSERT INTO MEM_CHECK 
VALUES(3, 'user03' , 'pass01' , '홍길동', '국' ,NULL,NULL);
-- CHECK 제약조건 위배

/* 
    * DEFAULT 설정
      특정 칼럼에 들어올 값에 대한 기본값 설정.(제약조건은 아님)
      
      회원가입일 컬럼에 회원정보가 삽입되는 순간 현재시간정보를 기록.
*/

DROP TABLE MEM_CHECK;

CREATE TABLE MEM_CHECK (
    MEM_NO NUMBER NOT NULL CONSTRAINT MEM_UNIQUE_UQ_MEM_NO UNIQUE,
    MEM_ID VARCHAR2(20) NOT NULL ,
    MEM_PWD VARCHAR2(20) NOT NULL,
    MEM_NAME VARCHAR2(20) NOT NULL,
    GENDER CHAR(3)NOT NULL CHECK(GENDER IN ('남','여') ) , 
    PHONE VARCHAR2(15),
    EMAIL VARCHAR2(30),
    MEM_DATE DATE DEFAULT SYSDATE,
    
   CONSTRAINT MEM_UNIQUE_UQ_MEM_ID UNIQUE(MEM_ID)
);

INSERT INTO MEM_CHECK 
VALUES(1, 'user01' , 'pass01' , '홍길동', NULL,NULL,NULL,NULL);

INSERT INTO MEM_CHECK 
VALUES(2, 'user02' , 'pass01' , '홍길동', NULL,NULL,NULL,DEFAULT);

INSERT INTO MEM_CHECK(MEM_NO, MEM_ID, MEM_PWD, MEM_NAME)
VALUES (3, 'user03', 'pass03' ,'김길동');

SELECT * FROM MEM_CHECK;

DROP TABLE MEM_CHECK;

/* 
    4. PRIMARY KEY(기본 키) 제약조건
       테이블에서 각 행들의 정보를 유일하게 식별할 수 있는 컬럼에 부여하는 제약조건.
       -> 각 행들을 구분할수 있는 식별자의 역할.
          EX) 사번, 회원번호, 부서아이디, 직급코드....
       -> 식별자의 조건 : 중복 X, 값이 반드시 존재해야한다. -> UNIQUE + NOT NULL
       
       기본키 제약조건은 테이블에 한개만 지정가능함.
*/
DROP TABLE MEM_CHECK;

CREATE TABLE MEM_PRIMARYKEY(
    MEM_NO NUMBER PRIMARY KEY,
    MEM_ID VARCHAR2(20) NOT NULL ,
    MEM_PWD VARCHAR2(20) NOT NULL,
    MEM_NAME VARCHAR2(20) NOT NULL,
    GENDER CHAR(3)NOT NULL CHECK(GENDER IN ('남','여') ) , 
    PHONE VARCHAR2(15),
    EMAIL VARCHAR2(30),
    MEM_DATE DATE DEFAULT SYSDATE
);

INSERT INTO MEM_PRIMARYKEY 
VALUES (1, 'user01' , 'pass01' , '홍길동', '남',NULL,NULL,NULL);

INSERT INTO MEM_PRIMARYKEY 
VALUES (2, 'user02' , 'pass01' , '홍길동', '남',NULL,NULL,NULL);

DROP TABLE MEM_PRIMARYKEY;

CREATE TABLE MEM_PRIMARYKEY(
    MEM_NO NUMBER,
    MEM_ID VARCHAR2(20) NOT NULL UNIQUE,
    MEM_PWD VARCHAR2(20) NOT NULL,
    MEM_NAME VARCHAR2(20) NOT NULL,
    GENDER CHAR(3)NOT NULL CHECK(GENDER IN ('남','여') ) , 
    PHONE VARCHAR2(15),
    EMAIL VARCHAR2(30),
    MEM_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT MEM_PRIMARYKEY_PK_MEM_NO PRIMARY KEY(MEM_NO)
);

-- 두칼럼을 합쳐서 기본키로 설정
CREATE TABLE MEM_PRIMARYKEY(
    MEM_NO NUMBER,
    MEM_ID VARCHAR2(20) NOT NULL UNIQUE,
    MEM_PWD VARCHAR2(20) NOT NULL,
    MEM_NAME VARCHAR2(20) NOT NULL,
    GENDER CHAR(3)NOT NULL CHECK(GENDER IN ('남','여') ) , 
    PHONE VARCHAR2(15),
    EMAIL VARCHAR2(30),
    MEM_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT MEM_PRIMARYKEY_PK_MEM_NO PRIMARY KEY(MEM_NO, MEM_ID)
);

INSERT INTO MEM_PRIMARYKEY 
VALUES (1, 'user01' , 'pass01' , '홍길동', '남',NULL,NULL,NULL);

INSERT INTO MEM_PRIMARYKEY 
VALUES (1, 'user02' , 'pass01' , '홍길동', '남',NULL,NULL,NULL);

INSERT INTO MEM_PRIMARYKEY 
VALUES (1, 'user02' , 'pass01' , '홍길동', '남',NULL,NULL,NULL);

/*
   5. FOREIGN KEY (외래 키)
      해당 컬럼에 다른 테이블에 존재하는 값만 들어와야 하는 컬럼에 부여하는 제약조건
      => 다른 테이블을 "참조"한다 라고 표현
         즉, 참조된 다른 테이블(부모테이블)이 제공하는 값만 들어올 수 있다.
      => FOREIGN KEY 제약조건 다른 테이블과의 관계형성을 한다. (외래키 제약조건이 걸린 칼럼을 통해 JOIN하는것이 일반적) 
      
      [표현법]
      > 컬럼레벨 방식
      컬럼명 자료형 CONSTRAINT 제약조건 이름 REFERENCES 참조할 테이블명(참조할 컬럼명)
      
      > 테이블레벨 방식
      CONSTRAINT 제약조건 이름 FOREIGN KEY(칼럼명) REFERENCES 참조할 테이블명 (참조할 컬럼명);
      
      주의사항 : 참조할 칼럼의 타입과 외래키로 지정할 컬럼의 타입이 같아야한다.
      
      참조할 컬럼명은 생략 가능. (참조할 테이블의 PK값을 기본값으로 지정하기 때문)
 */

-- 부모테이블 생성
-- 회원등급에 대한 데이터 보관하는 테이블
CREATE TABLE MEM_GRADE(
    GRADE_CODE CHAR(2) PRIMARY KEY ,
    GRADE_NAME VARCHAR2(20) NOT NULL
);

INSERT INTO MEM_GRADE VALUES('G1', '일반등급');

INSERT INTO MEM_GRADE VALUES('G2', '우수등급');

INSERT INTO MEM_GRADE VALUES('G3', '특별등급');

DROP TABLE MEM_PRIMARYKEY;

CREATE TABLE MEM(
    MEM_NO NUMBER,
    MEM_ID VARCHAR2(20) NOT NULL UNIQUE,
    MEM_PWD VARCHAR2(20) NOT NULL,
    MEM_NAME VARCHAR2(20) NOT NULL,
    GRADE_ID CHAR(2), -- REFERENCES MEM_GRADE(GRADE_CODE),
    GENDER CHAR(3)NOT NULL CHECK(GENDER IN ('남','여') ) , 
    PHONE VARCHAR2(15),
    EMAIL VARCHAR2(30),
    MEM_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT MEM_PK_MEM_NO PRIMARY KEY(MEM_NO),
    CONSTRAINT MEM_FK_GRADE_ID FOREIGN KEY(GRADE_ID) REFERENCES MEM_GRADE/*(GRADE_CODE)*/
);

INSERT INTO MEM 
VALUES (1, 'user01' , 'pass01' , '홍길동', 'G1', '남',NULL,NULL,NULL);

INSERT INTO MEM 
VALUES (2, 'user02' , 'pass01' , '김길동', 'G2', '남',NULL,NULL,NULL);

INSERT INTO MEM 
VALUES (3, 'user03' , 'pass01' , '정길동', 'G3', '여',NULL,NULL,NULL);

INSERT INTO MEM 
VALUES (4, 'user04' , 'pass01' , '민길동', 'G4', '여',NULL,NULL,NULL);
-- 부모테이블에 G4등급이 없기 때문에 에러발생.

INSERT INTO MEM 
VALUES (4, 'user04' , 'pass01' , '민길동', NULL, '여',NULL,NULL,NULL);
-- NULL값은 추가 가능하다.

-- 만약 부모테이블에서 G1인 등급이 삭제된다면?
DELETE FROM MEM_GRADE WHERE GRADE_CODE = 'G1';
-- 자식 테이블에서 G1칼럼값을 "참조" 하고 있기 때문에 삭제 불가능
-- 삭제 제한 옵션이 걸려있음.

DELETE FROM MEM WHERE GRADE_ID = 'G1';

/*
   * 자식테이블 생성시 외래키 제약조건을 부여할때 부모테이블의 데이터가 삭제되었을때
     자식테이블에서는 어떤식으로 처리할지 옵션을 기술할 수 있다.

   * FOREIGN KEY 삭제 옵션
    - ON DELETE RESTRICTED : 삭제 제한 -> 기본옵션
    - ON DELETE SET NULL   : 부모데이터를 삭제할때 해당 데이터를 참조하고 있는 자식데이터 칼럼을 NULL로 치환.
    - ON DELETE CASCADE    : 부모데이터를 삭제할때 해당 데이터를 참조하고 있는 자식데이터의 행을 함께 삭제한다.
*/

DROP TABLE MEM;

CREATE TABLE MEM(
    MEM_NO NUMBER,
    MEM_ID VARCHAR2(20) NOT NULL UNIQUE,
    MEM_PWD VARCHAR2(20) NOT NULL,
    MEM_NAME VARCHAR2(20) NOT NULL,
    GRADE_ID CHAR(2), -- REFERENCES MEM_GRADE(GRADE_CODE),
    GENDER CHAR(3)NOT NULL CHECK(GENDER IN ('남','여') ) , 
    PHONE VARCHAR2(15),
    EMAIL VARCHAR2(30),
    MEM_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT MEM_PK_MEM_NO PRIMARY KEY(MEM_NO),
    CONSTRAINT MEM_FK_GRADE_ID FOREIGN KEY(GRADE_ID) REFERENCES MEM_GRADE ON DELETE CASCADE
    -- ON DELETE SET NULL /*(GRADE_CODE) ON DELETE RESTR*/
);

INSERT INTO MEM 
VALUES (1, 'user01' , 'pass01' , '홍길동', 'G1', '남',NULL,NULL,NULL);

INSERT INTO MEM 
VALUES (2, 'user02' , 'pass01' , '김길동', 'G2', '남',NULL,NULL,NULL);

INSERT INTO MEM 
VALUES (3, 'user03' , 'pass01' , '정길동', 'G3', '여',NULL,NULL,NULL);

SELECT * FROM MEM;

DELETE FROM MEM_GRADE WHERE GRADE_CODE = 'G2';

--------------------------------------------------------------------------------
/*
    * SUBQUERY를 이용한 테이블 생성(테이블 복사본)
      메인 SQL문을 보조하는 역할의 쿼리 == 서브쿼리
      
      [표현법]
      CREATE TABLE 테이블명 AS 서브쿼리;
*/

SELECT * FROM EMPLOYEE;

CREATE TABLE EMPLOYEE_COPY
AS SELECT * FROM EMPLOYEE;

SELECT * FROM EMPLOYEE_COPY;
-- 컬럼명, 자료형, 행데이터, NOT NULL제약조건 까지는 제대로 복사가 이루어짐.
-- 단, PRIMARY KEY, UNIQUE, FOREIGN KEY등은 복사가 제대로 안된다.

CREATE TABLE EMPLOYEE_COPY2
AS 
SELECT * FROM EMPLOYEE WHERE 1 = 0;

-- 전체 사원들중 급여가 300만원 이상인 사원들의 사번, 이름, 부서코드, 급여
CREATE TABLE EMPLOYEE_COPY3
AS
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY >= 3000000;

SELECT * FROM EMPLOYEE_COPY3;

-- 전체 사원의 사번, 사원명, 급여, 연봉을 조회한 결과를 복제한 테이블 생성.
CREATE TABLE EMPLOYEE_COPY4
AS
SELECT EMP_ID, EMP_NAME, SALARY, SALARY * 12 AS 연봉
FROM EMPLOYEE;

SELECT * FROM EMPLOYEE_COPY4;




