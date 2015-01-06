" Date Create: 2015-01-06 13:15:51
" Last Change: 2015-01-06 13:21:42
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Test = {}

"" {{{1
" @var integer Время работы теста в секундах.
"" 1}}}
let s:runtime = 0
"" {{{1
" @var integer Число запущенных тестов.
"" 1}}}
let s:Test.countTests = 0
"" {{{1
" @var integer Число допущенных предположений (проверок).
"" 1}}}
let s:Test.countAsserting = 0
"" {{{1
" @var integer Число нарушений.
"" 1}}}
let s:Test.countFail = 0
"" {{{1
" @var integer Порядковые номера допущенных предположений (проверок).
"" 1}}}
let s:Test.countTestAsserting = 0

"" {{{1
" Запуск метода вызываемого объекта для тестирования.
" @param string methodName Имя запускаемого метода.
"" 1}}}
function! s:Test._runMethod(methodName) " {{{1
  let self.countTestAsserting = 0
  let self.countTests += 1
  call self.beforeTest()
  echo '---' . a:methodName . '---'
  let l:runtime = localtime()
  call self[a:methodName]()
  let self.runtime += localtime() - l:runtime
  call self.afterTest()
endfunction " 1}}}

"" {{{1
" Метод выполняет сверку данных и сообщает о несоответствии.
" @param string funName Имя метода, запросившего сверку. Данное имя используется в тексте о несоответствии.
" @param mixed assertValue Ожидаемые данные.
" @param mixed actualValue Настоящие данные.
"" 1}}}
function! s:Test._compare(funName, assertValue, actualValue) " {{{1
  let l:assertType = type(a:assertValue)
  let l:actualType = type(a:actualValue)
  if l:assertType != l:actualType || a:assertValue != a:actualValue
    call self.fail(a:funName, 'Failed asserting that <' . l:assertType . ':' . string(a:assertValue) . '> matches expected value <' . l:actualType . ':' . string(a:actualValue) . '>.')
  endif
endfunction " 1}}}

"" {{{1
" Метод вызывается для провальных тестов.
" @param string funName Имя провального теста.
" @param string message Сообщение о провале.
"" 1}}}
function! s:Test.fail(funName, message) " {{{1
  let self.countFail += 1
  echo a:funName . '[' . self.countTestAsserting . ']: ' . a:message
endfunction " 1}}}

"" {{{1
" Предположение истинности.
" @param bool actual Проверяемое значение.
"" 1}}}
function! s:Test.assertTrue(actual) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  call self._compare('assertTrue', 1, a:actual)
endfunction " 1}}}

"" {{{1
" Предположение ложности.
" @param bool actual Проверяемое значение.
"" 1}}}
function! s:Test.assertFalse(actual) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  call self._compare('assertFalse', 0, a:actual)
endfunction " 1}}}

"" {{{1
" Предположение равенства целых чисел.
" @param integer assert Ожидаемое значение.
" @param integer actual Проверяемое значение.
"" 1}}}
function! s:Test.assertInteger(assert, actual) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  call self._compare('assertInteger', a:assert, a:actual)
endfunction " 1}}}

"" {{{1
" Предположение равенства дробных чисел.
" @param float assert Ожидаемое значение.
" @param float actual Проверяемое значение.
"" 1}}}
function! s:Test.assertFloat(assert, actual) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  call self._compare('assertFloat', a:assert, a:actual)
endfunction " 1}}}

"" {{{1
" Предположение равенства строк.
" @param string assert Ожидаемое значение.
" @param string actual Проверяемое значение.
"" 1}}}
function! s:Test.assertString(assert, actual) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  call self._compare('assertString', a:assert, a:actual)
endfunction " 1}}}

"" {{{1
" Предположение отсутствия данных (пустая строка или пустой массив).
" @param string|array actual Проверяемое значение.
"" 1}}}
function! s:Test.assertEmpty(actual) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  if type(a:actual) == 1
    call self._compare('assertEmpty', '', a:actual)
  elseif type(a:actual) == 3
    call self._compare('assertEmpty', [], a:actual)
  endif
endfunction " 1}}}

"" {{{1
" Предположение наличия данных (не пустая строка или не пустой массив).
" @param string|array actual Проверяемое значение.
"" 1}}}
function! s:Test.assertNotEmpty(actual) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  if (type(a:actual) == 1 && strlen(a:actual) == 0) || (type(a:actual) == 3 && len(a:actual) == 0)
    call self.fail('assertNotEmpty', 'Failed assert that <' . type(a:actual) . ':' . string(a:actual) . '> is the empty value.')
  endif
endfunction " 1}}}

"" {{{1
" Предположение равенства массивов.
" @param array assert Ожидаемое значение.
" @param array actual Проверяемое значение.
"" 1}}}
function! s:Test.assertArray(assert, actual) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  call self._compare('assertArray', a:assert, a:actual)
endfunction " 1}}}

"" {{{1
" Предположения наличия значения в массиве.
" @param array array Проверяемый массив.
" @param mixed Искомое значение.
"" 1}}}
function! s:Test.assertArrayContains(array, element) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  if index(a:array, a:element) == -1
    call self.fail('assertArrayContains', 'Failed assert that <' . type(a:array) . ':' . string(a:array) . '> conrains value <' . type(a:element) . ':' . string(a:element) . '>.')
  endif
endfunction " 1}}}

"" {{{1
" Предположения отсутствия значения в массиве.
" @param array array Проверяемый массив.
" @param mixed Искомое значение.
"" 1}}}
function! s:Test.assertArrayNotContains() " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  if index(a:array, a:element) != -1
    call self.fail('assertArrayNotContains', 'Failed assert that <' . type(a:array) . ':' . string(a:array) . '> not conrains value <' . type(a:element) . ':' . string(a:element) . '>.')
  endif
endfunction " 1}}}

"" {{{1
" Предположение равенства хэш-таблиц.
" @param hash assert Ожидаемое значение.
" @param hash actual Проверяемое значение.
"" 1}}}
function! s:Test.assertDict(assert, actual) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  call self._compare('assertDict', a:assert, a:actual)
endfunction " 1}}}

"" {{{1
" Предположения наличия ключа в хэш-таблице.
" @param hash dict Проверяемая хэш-таблица.
" @param string key Искомый ключ.
"" 1}}}
function! s:Test.assertDictHasKey(dict, key) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  if has_key(a:dict, a:key) == 0
    call self.fail('assertDictHasKey', 'Failed assert that <' . type(a:dict) . ':' . string(a:dict) . '> contains key <' . type(a:key) . ':' . string(a:key) . '>.')
  endif
endfunction " 1}}}

"" {{{1
" Предположения отсутствия ключа в хэш-таблице.
" @param hash dict Проверяемая хэш-таблица.
" @param string key Искомый ключ.
"" 1}}}
function! s:Test.assertDictNotHasKey(dict, key) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  if has_key(a:dict, a:key) != 0
    call self.fail('assertDictNotHasKey', 'Failed assert that <' . type(a:dict) . ':' . string(a:dict) . '> not contains key <' . type(a:key) . ':' . string(a:key) . '>.')
  endif
endfunction " 1}}}

"" {{{1
" Предположение равенства функций.
" @param function assert Ожидаемое значение.
" @param function actual Проверяемое значение.
"" 1}}}
function! s:Test.assertFun(assert, actual) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  call self._compare('assertFun', a:assert, a:actual)
endfunction " 1}}}

"" {{{1
" Предположение эквивалентности значений.
" @param mixed assert Ожидаемое значение.
" @param mixed actual Проверяемое значение.
"" 1}}}
function! s:Test.assertEquals(assert, actual) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  call self._compare('assertEquals', a:assert, a:actual)
endfunction " 1}}}

"" {{{1
" Предположение не эквивалентности значений.
" @param mixed assert Недопустимое значение.
" @param mixed actual Проверяемое значение.
"" 1}}}
function! s:Test.assertNotEquals(assert, actual) " {{{1
  let self.countAsserting += 1
  let self.countTestAsserting += 1
  let l:assertType = type(a:assertValue)
  let l:actualType = type(a:actualValue)
  if l:assertType == l:actualType && a:assertValue == a:actualValue
    call self.fail('assertNotEquals', 'Failed asserting that <' . l:assertType . ':' . string(a:assertValue) . '> not equals value <' . l:actualType . ':' . string(a:actualValue) . '>.')
  endif
endfunction " 1}}}

"" {{{1
" Метод выполняет тестирование.
" @param string methodName [optional] Имя запускаемого метода для тестирования. Если параметр не передан, запускаются все методы класса, название которых начинается на "test".
"" 1}}}
function! s:Test.run(...) " {{{1
  let self.countTests = 0
  let self.countAsserting = 0
  let self.countFail = 0
  let self.runtime = 0
  call self.beforeRun()
  if exists('a:1')
    call self._runMethod(a:1)
  else
    for l:i in keys(self)
      if type(self[l:i]) == 2 && strpart(l:i, 0, 4) == 'test'
        call self._runMethod(l:i)
      endif
    endfor
  endif
  call self.afterRun()
  echo ''
  echo 'Time: ' . self.runtime . 's'
  if self.countFail == 0
    echo 'OK'
  else
    echo 'FAILURES'
  endif
  echo '(Tests: ' . self.countTests . ', Assertions: ' . self.countAsserting . ', Failures: ' . self.countFail . ')'
endfunction " 1}}}

"" {{{1
" Данный метод вызывается перед запуском тестов.
"" 1}}}
function! s:Test.beforeRun() " {{{1
endfunction " 1}}}

"" {{{1
" Данный метод вызывается перед запуском каждого тестового метода.
"" 1}}}
function! s:Test.beforeTest() " {{{1
endfunction " 1}}}

"" {{{1
" Данный метод вызывается после выполнения каждого тестового метода.
"" 1}}}
function! s:Test.afterTest() " {{{1
endfunction " 1}}}

"" {{{1
" Данный метод вызывается после завершения тестирования.
"" 1}}}
function! s:Test.afterRun() " {{{1
endfunction " 1}}}

let g:vim_lib#base#Test# = s:Test
