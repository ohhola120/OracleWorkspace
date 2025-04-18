/*
   <SUBQUERY>
   
   하나의 주된 SQL(SELECT, INSERT, DELETE, UPDAT, CREATE..)안에 포함된 또하나의 SELECT문
   
   메인 SQL문을 위해서 보조 역할을 한다.
   => SELECT, FROM, WHERE, HAVING절 등 다양한 위치에서 사용가능하며, 사용되는 위치마다 부르는 명칭이 다름.
   => SELECT => 스칼라 서브쿼리 -> 스칼라(하나의 값)을 반환해주는 서브쿼리
   => FROM => 인라인 뷰(파생테이블) -> VIEW라는 객체를 인라인에 정의했다라는 의미, 서브쿼리의 조회결과를 테이블처럼 활용.
   => WHERE , HAVING => 프레디케이트 서브쿼리 --> 조건검사에 사용되는 서브쿼리
*/

-- 간단 서브쿼리 예시 1
-- 1) 노홍철 사원과 같은 부서인 사원들 정보를 조회.
SELECT DEPT_CODE
FROM EMPLOYEE
WHERE EMP_NAME = '노옹철';

SELECT *
FROM EMPLOYEE
WHERE DEPT_CODE = 'D9';

-- 두 쿼리를 하나로 합치기
SELECT *
FROM EMPLOYEE
WHERE DEPT_CODE = ( SELECT DEPT_CODE
                    FROM EMPLOYEE
                    WHERE EMP_NAME = '노옹철' );

-- 예시 2) 전체 사원의 평균 급여보다 더 많이 받고있는 사원들의 사번, 이름, 직급코드 조회
-- 1) 전체사원의 평균급여
SELECT ROUND (AVG (SALARY))
FROM EMPLOYEE;

SELECT EMP_ID, EMP_NAME, JOB_CODE
FROM EMPLOYEE
WHERE SALARY > (SELECT ROUND(AVG(SALARY)) FROM EMPLOYEE);

/*
   서브쿼리 구분
   서브쿼리를 수행한 결과값이 몇행 몇열이냐에 따라서 분류됨.
   
   - 단일행 (단일열) 서브쿼리 : 서브쿼리를 수행한 결과값이 오직 1개일때
   - 다중행 (단일열) 서브쿼리 : 서브쿼리를 수행한 결과값이 여러 행일때
   - (단일행) 다중열 서브쿼리 : 서브쿼리를 수행한 결과값이 여러 열일때
   - 다중행 다중열 서브쿼리   : 서브쿼리를 수행한 결과값이 여러행 여러 열일때
*/
/*
   1. 단일행 (단일열) 서브쿼리
      서브쿼리의 조회 결과값이 오직 1개일 때
      
   일반 연산자들 활용가능(=, !=, >=, <=...)
*/
-- 전 직원의 평균 급여보다 더 적게 받는 사원들의 사원명, 직급코드, 급여 조회
SELECT EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY = (SELECT MIN(SALARY) FROM EMPLOYEE); 

-- 노올철 사원의 급여보다 더 많이 받는 사원들의 사번, 이름, 부서명, 급여를 조회
--> 오라클 전용구문
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, SALARY
FROM EMPLOYEE, DEPARTMENT
WHERE EMPLOYEE.DEPT_CODE = DEPT_ID(+) AND
SALARY > (SELECT SALARY FROM EMPLOYEE WHERE EMP_NAME + '노옹철');

--> ANSI 구문
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, SALARY
FROM EMPLOYEE

-- 부서별 급여 합이 가장 큰 부서 하나만을 조회. 부서코드, 부서명, 급여의 합
--1) 각 부서별 급여의 합을 구한후 최대값 찾기

SELECT 
      MAX(SUM(SALARY))
FROM EMPLOYEE
GROUP BY DEPT_CODE;

-- 2) 메인쿼리문 작성
SELECT DEPT_CODE, DEPT_TITLE, SUM(SALARY) 급여의합
FROM EMPLOYEE
LEFT JOIN DEPARTMENT ON DEPT_CODE = DEPT_ID
GROUP BY DEPT_CODE, DEPT_TITLE
HAVING SUM(SALARY) = (SELECT 
                      MAX(SUM(SALARY))
                      FROM EMPLOYEE
                      GROUP BY DEPT_CODE);
--------------------------------------------------------------------------------
/*
   2. 다중행 서브쿼리
   
   서브쿼리 조회 결과값이 여러행일 경우
   
   - 칼럼 IN (10,20,30) : 여러개의 결과값중 하나라도 일치하는것이 있다면
   
   - 칼럼 > ANY (10,20,30)   : 여러개의 결과값중 "하나라도" 칼럼값이 더 클경우
   
   - 칼럼 < ANY (서브쿼리) : 여러개의 결과값들 중 하나라도 더 작은값이 있을경우

   - 칼럼[> / <] ALL(서브쿼리) : 여러개의 결과값들과 "모두 비교해봤을때 크거나 작을경우 참.
*/
-- 각 부서별 최고급여를 받는 사원들의 이름, 직급코드, 급여 조회
-- 1) 각 부서별 최고급여들 조회
SELECT MAX(SALARY)
FROM EMPLOYEE
GROUP BY DEPT_CODE;

-- 2) 위의 급여를 받는 사원들 조회
SELECT EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY IN ( 8000000,
                  3900000,
                  3760000,
                  2550000,
                  2890000,
                  3660000,
                  2490000);
SELECT EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY IN ( SELECT MAX(SALARY) FROM EMPLOYEE GROUP BY DEPT_CODE);

-- 이오리 또는 하동운 사원과 같은 직급인 사원들을 조회하시오(사원명, 직급코드, 부서코드, 급여)
SELECT EMP_NAME, JOB_CODE, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE JOB_CODE IN ( SELECT JOB_CODE
                    FROM EMPLOYEE
                    -- WHERE EMP_NAME = '하동운' OR EMP_NAME = '이오리'
                    WHERE EMP_NAME IN ('하동운','이오리'));

-- 사원 < 대리 < 과장 < 차장 < 부장
-- 대리 직급임에도 불구하고 과장보다 더 많은 급여를 받은 사원들 정보를 조회(사번, 이름, 직급명, 급여)
-- 1) 과장지급의 급여들 조회
SELECT SALARY
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
WHERE JOB_NAME = '과장';

-- 2) 위의 급여들보다 하나라도더 높은 급여를 받는 직원들 조회
SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
WHERE JOB_NAME = '대리' AND SALARY >= ANY(2200000,2500000,2760000);

SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
WHERE JOB_NAME = '대리' AND SALARY >= ANY(
    SELECT SALARY
    FROM EMPLOYEE
    JOIN JOB USING(JOB_CODE)
    WHERE JOB_NAME = '과장');

-- 과장 직급임에도 "모든" 차장직급의 급여보다도 더 많이 받는 직원정보 조회(사번, 이름, 직급명, 급여)
SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
 WHERE JOB_NAME = '과장' AND SALARY >= ALL(
                                      SELECT SALARY
                                      FROM EMPLOYEE
                                      JOIN JOB USING(JOB_CODE)
                                      WHERE JOB_NAME ='차장');
/*
    3. (단일행) 다중열 서브쿼리
    서브쿼리 조회 결과가 단일행이지만, 나열된 칼럼의 갯수가 여러개인경우.
*/
-- 하이유 사원과 같은 부서코드이면서 같은 직급코드에 해당되는 사원들 조회(사원명, 부서코드, 직급코드, 고용날)
SELECT DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE EMP_NAME = '하이유'

SELECT EMP_NAME, DEPT_CODE, JOB_CODE, HIRE_DATE
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5' AND JOB_CODE = 'J5';

--다중열 서브쿼리 (비교할 값의 순서를 맞춰줘야함.
-- (비교대상 칼럼1, 비교대상 칼럼2, ...) = (비교할값1 , 비교할값2, ...)

SELECT EMP_NAME, DEPT_CODE, JOB_CODE, HIRE_DATE
FROM EMPLOYEE
WHERE (DEPT_CODE, JOB_CODE) = (SELECT DEPT_CODE, JOB_CODE
                                            FROM EMPLOYEE
                                  WHERE EMP_NAME = '하이유');

-- 박나라 사원과 같은 직급코드이면서 같은 사수사번을 가진 사원들의 사번, 이름, 직급코드, 사수사번, 조회(다중열 서브쿼리로 작성)
SELECT EMP_ID, EMP_NAME, JOB_CODE, MANAGER_ID
FROM EMPLOYEE
WHERE (JOB_CODE, MANAGER_ID) = (
     SELECT JOB_CODE, MANAGER_ID FROM EMPLOYEE WHERE EMP_NAME = '박나라');
     -- AND EMP_NAME != '박나라'; 자신 빼고 나오게 하려면 추가로 제시
/*
   4. 다중행 다중열 서브쿼리
   서브쿼리 조회 결과가 여러행 여러컬럼일 경우
*/   
-- 각 직급별로 최소 급여를 받는 사원들 조회(사번, 이름, 직급코드, 급여)
SELECT JOB_CODE, MIN(SALARY)
FROM EMPLOYEE
GROUP BY JOB_CODE;

SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
/*WHERE (JOB_CODE, SALARY) = ('J1', 8000000)
   OR (JOB_CODE, SALARY) = ('J2', 37000000)
   ...
   (JOB_CODE, SALARY) = IN ( ('J1', 8000000),('J2', 37000000) )
   다중행 다중열로 만들어야함
*/ 
WHERE (JOB_CODE, SALARY) IN(
    SELECT JOB_CODE, MIN(SALARY)
    FROM EMPLOYEE
    GROUP BY JOB_CODE);

-- 각 부서별 최고급여를 받는 사원을 조회, 부서가 없을경우 NULL값이 아닌 '부서없음'으로 조회되게끔 하시오
-- (사번, 이름, 부서코드, 급여)
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE (JOB_CODE, SALARY) IN(
    SELECT JOB_CODE, MAX(SALARY)
    FROM EMPLOYEE
    GROUP BY JOB_CODE);
/* 
    5. 스칼라 서브쿼리
     - 단일행(단일열) 서브쿼리의 일종으로 SELECT절에서 사용되는 서브쿼리를 지칭함.
       SELECT절이 실행 될때마다 서브쿼리문이 실행되면서 조회결과값을 반환.
     - 현재 조회된 행의 "칼럼값"을 서브쿼리 내에서 사용가능함.
     - 매행마다 실행되기때문에 대규모 데이터처리시 효율이 좋지 못함.
*/
-- 직원번호, 직원명, 부서명을 조회
SELECT EMP_ID, 
       EMP_NAME,
       DEPT_TITLE
FROM EMPLOYEE
JOIN DEPARTMENT ON DEPT_CODE = DEPT_ID;

SELECT EMP_ID,
       EMP_NAME,
       (SELECT DEPT_TITLE FROM DEPARTMENT WHERE DEPT_ID = DEPT_CODE) AS DEPT_TITLE
FROM EMPLOYEE;

-- 사번, 사원명, 부서코드, 직급명조회
SELECT 
    EMP_ID,
    EMP_NAME,
    DEPT_CODE,
    (SELECT JOB_NAME FROM JOB J WHERE J.JOB_CODE = E.JOB_CODE) AS JOB_NAME
FROM EMPLOYEE E;

-- LOCATION 테이블에서 지역코드와, 국가명(스칼라 서브쿼리를 활용) 조회하기 
SELECT LOCAL_CODE, 
      (SELECT NATIONAL_NAME FROM NATIONAL WHERE NATIONAL_CODE = L.NATIONAL_CODE)
FROM LOCATION L;

--------------------------------------------------------------------------------
/*
    6. 인라인 뷰
    - FROM절에서 사용되는 서브쿼리
    
    서브쿼리를 수행한 결과(RESULT SET)을 테이블 대신 사용. 파생테이블
*/
-- 보너스 포함 연봉이 3000만원 이상인 사원들의 사번, 이름, 보너스포함 연봉, 부서코드 조회
SELECT EMP_NAME
FROM (SELECT EMP_ID, 
             EMP_NAME, 
             (SALARY + SALARY * NVL(BONUS, 0)) * 12 "보너스 포함 연봉",
             DEPT_CODE
FROM EMPLOYEE )
-- WHERE (SALARY + SALARY * NVL(BONUS, 0)) *12 >= 30000000
WHERE "보너스 포함 연봉" >= 30000000; -- 보너스 포함 연봉이 먼저 데이터로 생성된 후 칼럼을 사용하였으므로 문제없다.

-- 인라인뷰를 많이 사용하는 예
-- TOP-N분석 : 데이터 베이스상에 있는 자료들중 최상위 N개의 자료를 보기 위한 기능

-- 전 직원중 급여가 가장 높은 상위 5명을 조회(순위, 사원명, 급여)
SELECT *
FROM(
    SELECT ROW_NUMBER() OVER(ORDER BY SALARY DESC) "순위" , EMP_ID, SALARY
    FROM EMPLOYEE)
WHERE "순위" <= 5;

-- * ROWNUM : 오라클에서 제공해주는 칼럼, 조회된 순서대로 1부터 순번을 부여해주는 칼럼
SELECT EMP_NAME, SALARY, ROWNUM
FROM EMPLOYEE
-- WHERE ROWNUM <= 5;
 ORDER BY SALARY DESC; -- 순서가 뒤엉키게 된다.

-- 1) ORDER BY로 테이블 먼저 정렬한 후, ROWNUM 순번을 통해 급여가 높은 5명만 추출
SELECT *
FROM (SELECT EMP_NAME, SALARY, ROWNUM AS R
   FROM (
          SELECT *
          FROM EMPLOYEE
          ORDER BY SALARY DESC))
WHERE R >= 5 AND R <= 10;

--------------------------------------------------------------------------------
-- 각 부서별 평균 급여가 높은 3개의 부서의 부서코드, 평균급여 조회
SELECT DEPT_CODE ,"ROUND(AVG(SALARY))"
FROM (
        SELECT DEPT_CODE ,ROUND(AVG(SALARY))
        FROM EMPLOYEE
        GROUP BY DEPT_CODE
        ORDER BY 2 DESC
     )R
WHERE ROWNUM <= 3;


















