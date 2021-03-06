﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиентСервер.ЭтоLinuxКлиент() Тогда
		Возврат; // Отказ устанавливается в ПриОткрытии().
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиентСервер.ЭтоВебКлиент() Тогда
		ВызватьИсключение НСтр("ru = 'Резервное копирование недоступно в веб-клиенте.'");
	КонецЕсли;
	
	Если Не ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда
		ВызватьИсключение НСтр("ru = 'В клиент-серверном варианте работы резервное копирование следует выполнять сторонними средствами (средствами СУБД).'");
	КонецЕсли;
	
	НастройкиРезервногоКопирования = РезервноеКопированиеИБСервер.НастройкиРезервногоКопирования();
	ПарольАдминистратораИБ = НастройкиРезервногоКопирования.ПарольАдминистратораИБ;
	Объект.КаталогСРезервнымиКопиями = НастройкиРезервногоКопирования.КаталогХраненияРезервныхКопий;
	
	Если ПолучитьСеансыИнформационнойБазы().Количество() > 1 Тогда
		
		Элементы.СтраницыСтатусаВосстановления.ТекущаяСтраница = Элементы.СтраницаАктивныеПользователи;
		
	КонецЕсли;
	
	// Первая часть проверки на сервере - если в информационной базе есть пользователи
	ТребуетсяВводПароля = (ПользователиИнформационнойБазы.ПолучитьПользователей().Количество() > 0);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ОбщегоНазначенияКлиентСервер.ЭтоLinuxКлиент() Тогда
		Отказ = Истина;
		ТекстСообщения = НСтр("ru = 'Резервное копирование недоступно в клиенте под управлением ОС Linux.'");
		ПоказатьПредупреждение(,ТекстСообщения);
		Возврат;
	КонецЕсли;
	
	ИнформацияОПользователе = СтандартныеПодсистемыКлиентПовтИсп.ПараметрыРаботыКлиента().ИнформацияОПользователе;
	
	// Вторая часть проверки на клиенте - если у текущего пользователя (администратор)
	// используется стандартная аутентификация и установлен пароль
	ТребуетсяВводПароля = ТребуетсяВводПароля И ИнформацияОПользователе.АутентификацияСтандартная И ИнформацияОПользователе.ПарольУстановлен;
	
	Если ТребуетсяВводПароля Тогда
		АдминистраторИБ = ИнформацияОПользователе.Имя;
	Иначе
		Элементы.ГруппаАвторизации.Видимость = Ложь;
	КонецЕсли;
	
	ИмяФайлаЗапускаПриложенияВРежимеПредприятия = ПолучитьИмяФайлаЗапускаПриложенияВРежимеПредприятия();
	
#Если ВебКлиент Тогда
	Элементы.ГруппаComcntrФайловыйРежим.Видимость = Ложь;
#КонецЕсли
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, СтандартнаяОбработка)
	
	ТекущаяСтраница = Элементы.СтраницыЗагрузкиДанных.ТекущаяСтраница;
	Если ТекущаяСтраница = Элементы.СтраницыЗагрузкиДанных.ПодчиненныеЭлементы.СтраницаИнформацииИВыполненияРезервногоКопирования Тогда
		
		ТекстПредупреждения = НСтр("ru = 'Прервать подготовку к восстановлению данных?'");
		ОбщегоНазначенияКлиент.ПоказатьПодтверждениеЗакрытияПроизвольнойФормы(ЭтотОбъект,
			Отказ, ТекстПредупреждения, "ЗакрытьФормуБезусловно");
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	
	ОтключитьОбработчикОжидания("ИстечениеВремениОжидания");
	ОтключитьОбработчикОжидания("ПроверкаНаЕдинственностьПодключения");
	ОтключитьОбработчикОжидания("ЗавершитьРаботуПользователей");

КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	Если ИмяСобытия = "ЗавершениеРаботыПользователей" И Параметр.КоличествоСеансов <= 1
		И Элементы.СтраницыЗагрузкиДанных.ТекущаяСтраница = Элементы.СтраницаИнформацииИВыполненияРезервногоКопирования Тогда
			НачатьРезервноеКопирование();
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПутьККаталогуАрхивовНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ВыбратьФайлРезервнойКопии();
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПользователейНажатие(Элемент)
	
	ОткрытьФорму("Обработка.АктивныеПользователи.Форма.ФормаСпискаАктивныхПользователей", , ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура НадписьОбновитьВерсиюКомпонентыОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылка, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОбщегоНазначенияКлиент.ЗарегистрироватьCOMСоединитель();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ФормаОтмена(Команда)
	
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура Готово(Команда)
	
	ОчиститьСообщения();
	
	Если Не ПроверитьЗаполнениеРеквизитов() Тогда
		Возврат;
	КонецЕсли;
	
	Страницы = Элементы.СтраницыЗагрузкиДанных;
	
	Если НЕ ПроверитьДоступКИБ() Тогда
		Элементы.СтраницыСтатусаВосстановления.ТекущаяСтраница = Элементы.СтраницыСтатусаВосстановления.ПодчиненныеЭлементы.СтраницаОшибкаПодключения;
		Возврат;
	КонецЕсли;

	Страницы.ТекущаяСтраница = Элементы.СтраницаИнформацииИВыполненияРезервногоКопирования; 
	Элементы.Закрыть.Доступность = Истина;
	ОбновитьКоличествоАктивныхПользователей();
	Элементы.Готово.Доступность = Ложь;
	
	УстановитьБлокировкуСоединений = Истина;
	СоединенияИБВызовСервера.УстановитьБлокировкуСоединений(Нстр("ru = 'Выполняется восстановление информационной базы.'"), "РезервноеКопирование");
	
	Если РезервноеКопированиеИБВызовСервера.КоличествоАктивныхПользователей() = 1 Тогда
		СоединенияИБКлиент.УстановитьПризнакРаботаПользователейЗавершается(УстановитьБлокировкуСоединений);
		СоединенияИБКлиент.ЗавершитьРаботуЭтогоСеанса(Ложь);
		НачатьРезервноеКопирование();
	Иначе
		СоединенияИБКлиент.УстановитьОбработчикиОжиданияЗавершенияРаботыПользователей(УстановитьБлокировкуСоединений);
		УстановитьОбработчикОжиданияНачалаРезервногоКопирования();
		УстановитьОбработчикОжиданияИстеченияТаймаутаРезервногоКопирования();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиВЖурналРегистрации(Команда)
	ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.ЖурналРегистрации", , ЭтотОбъект);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Функция ПолучитьИмяФайлаЗапускаПриложенияВРежимеПредприятия()
#Если ТонкийКлиент Тогда 
	Возврат "1cv8c.exe";
#Иначе
	Возврат "1cv8.exe";
#КонецЕсли
КонецФункции

// Подключает обработчик ожидания истечения таймаута перед принудительным стартом резервного копирования/восстановления данных.
&НаКлиенте
Процедура УстановитьОбработчикОжиданияИстеченияТаймаутаРезервногоКопирования()
	
	ПодключитьОбработчикОжидания("ИстечениеВремениОжидания", 300, Истина);
	
КонецПроцедуры

// Подключает обработчик ожидания при отложенном резервном копировании
&НаКлиенте
Процедура УстановитьОбработчикОжиданияНачалаРезервногоКопирования() 
	
	ПодключитьОбработчикОжидания("ПроверкаНаЕдинственностьПодключения", 60);
	
КонецПроцедуры

// Процедура обновляет заголовок гиперссылки количества активных пользователей.
&НаКлиенте
Процедура ОбновитьКоличествоАктивныхПользователей()
	
	Элементы.КоличествоАктивныхПользователей.Заголовок = РезервноеКопированиеИБВызовСервера.КоличествоАктивныхПользователей();
	
КонецПроцедуры

// Функция запрашивает у пользователя и возвращает путь к файлу или каталогу.
&НаКлиенте
Процедура ВыбратьФайлРезервнойКопии()
	
	ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогОткрытияФайла.Фильтр = НСтр("ru = 'Архив с резервной копией (*.zip)|*.zip'");
	ДиалогОткрытияФайла.Заголовок= НСтр("ru = 'Выберите файл резервной копии'");
	ДиалогОткрытияФайла.ПроверятьСуществованиеФайла = Истина;
	
	Если ДиалогОткрытияФайла.Выбрать() Тогда
		
		Объект.ФайлЗагрузкиРезервнойКопии = ДиалогОткрытияФайла.ПолноеИмяФайла;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ПроверитьЗаполнениеРеквизитов()
	
	РеквизитыЗаполнены = Истина;
	
	Если ТребуетсяВводПароля И ПустаяСтрока(ПарольАдминистратораИБ) Тогда
		ТекстСообщения = НСтр("ru = 'Не задан пароль администратора.'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "ПарольАдминистратораИБ");
		РеквизитыЗаполнены = Ложь;
	КонецЕсли;
	
	ИмяФайла = Объект.ФайлЗагрузкиРезервнойКопии;
	
	Если ПустаяСтрока(ИмяФайла) Тогда
		ТекстСообщения = НСтр("ru = 'Не выбран файл с резервной копией.'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "Объект.ФайлЗагрузкиРезервнойКопии");
		Возврат Ложь;
	КонецЕсли;
	
	ФайлАрхива = Новый Файл(ИмяФайла);
	Если ФайлАрхива.Расширение <> ".zip" Тогда
		
		ТекстСообщения = НСтр("ru = 'Выбранный файл не является архивом с резервной копией.'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "Объект.ФайлЗагрузкиРезервнойКопии");
		Возврат Ложь;
		
	КонецЕсли;
	
	ZipФайл = Новый ЧтениеZipФайла(ИмяФайла);
	Если ZipФайл.Элементы.Количество() <> 1 Тогда
		
		ТекстСообщения = НСтр("ru = 'Выбранный файл не является архивом с резервной копией (содержит более одного файла).'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "Объект.ФайлЗагрузкиРезервнойКопии");
		Возврат Ложь;
		
	КонецЕсли;
	
	ФайлВАрхиве = ZipФайл.Элементы[0];
	
	Если ВРЕГ(ФайлВАрхиве.Расширение) <> "1CD" Тогда
		
		ТекстСообщения = НСтр("ru = 'Выбранный файл не является архивом с резервной копией (не содержит файл информационной базы).'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "Объект.ФайлЗагрузкиРезервнойКопии");
		Возврат Ложь;
		
	КонецЕсли;
	
	Если ВРЕГ(ФайлВАрхиве.ИмяБезРасширения) <> "1CV8" Тогда
		
		ТекстСообщения = НСтр("ru = 'Выбранный файл не является архивом с резервной копией (неправильное имя файла информационной базы).'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "Объект.ФайлЗагрузкиРезервнойКопии");
		Возврат Ложь;
		
	КонецЕсли;
	
	Возврат РеквизитыЗаполнены;
	
КонецФункции

// Функция проверяет возможность подключения к информационной базе с текущими параметрами.
&НаКлиенте
Функция ПроверитьДоступКИБ()

	Результат = Истина;
	// В базовых версиях проверку подключения не осуществляем;
	// при некорректном вводе имени и пароля обновление завершится неуспешно.
	Если СтандартныеПодсистемыКлиентПовтИсп.ПараметрыРаботыКлиента().ЭтоБазоваяВерсияКонфигурации Тогда
		Возврат Результат;
	КонецЕсли;
	
	ПараметрыПодключения = ПараметрыАутентификацииАдминистратораОбновления();
	Попытка
		ОбщегоНазначенияКлиент.ЗарегистрироватьCOMСоединитель(Ложь);
		ComConnector = Новый COMОбъект(СтандартныеПодсистемыКлиентПовтИсп.ПараметрыРаботыКлиента().ИмяCOMСоединителя);
		СтрокаСоединенияИнформационнойБазы = ПараметрыПодключения.СтрокаСоединенияИнформационнойБазы + ПараметрыПодключения.СтрокаПодключения;
		Соединение = ComConnector.Connect(СтрокаСоединенияИнформационнойБазы);
	Исключение
		Результат = Ложь;
		ОбнаруженнаяОшибкаПодключения = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		ЖурналРегистрацииКлиент.ДобавитьСообщениеДляЖурналаРегистрации(РезервноеКопированиеИБКлиент.СобытиеЖурналаРегистрации(),
			"Ошибка", ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()), , Истина);
		КонецПопытки;
		
	Если Результат Тогда
		
		УстановитьПараметрыРезервногоКопирования();
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Процедуры обработчиков ожидания

&НаКлиенте
Процедура ИстечениеВремениОжидания()
	
	ОтключитьОбработчикОжидания("ПроверкаНаЕдинственностьПодключения");
	ОтменитьПодготовку();
	
КонецПроцедуры

&НаСервере
Процедура ОтменитьПодготовку()
	
	ИменаАктивныхСеансов = "";
	НомерТекущегоСеанса = НомерСеансаИнформационнойБазы();
	Для Каждого Сеанс Из ПолучитьСеансыИнформационнойБазы() Цикл
		Если Сеанс.НомерСеанса <> НомерТекущегоСеанса Тогда
			ИменаАктивныхСеансов = ИменаАктивныхСеансов + "• " + Сеанс + Символы.ПС;
		КонецЕсли;
	КонецЦикла;
	СтроковыеФункцииКлиентСервер.УдалитьПоследнийСимволВСтроке(ИменаАктивныхСеансов);
	
	ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
	НСтр("ru = 'Не удалось принудительно отключить сеансы:
	|
	|%1.
	|
	|Подготовка к восстановлению данных из резервной копии отменена.
	|Информационная база разблокирована.'"), ИменаАктивныхСеансов);
	
	Элементы.НадписьНеУдалось.Заголовок = ТекстСообщения;
	Элементы.СтраницыЗагрузкиДанных.ТекущаяСтраница = Элементы.СтраницаОшибокПриКопировании;
	Элементы.Готово.Видимость = Ложь;
	Элементы.Закрыть.Заголовок = НСтр("ru = 'Закрыть'");
	Элементы.Закрыть.КнопкаПоУмолчанию = Истина;
	
	СоединенияИБ.РазрешитьРаботуПользователей();
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверкаНаЕдинственностьПодключения()
	
	Если РезервноеКопированиеИБВызовСервера.КоличествоАктивныхПользователей() = 1 Тогда
		НачатьРезервноеКопирование();
	КонецЕсли;
	
КонецПроцедуры                 

&НаКлиенте
Процедура НачатьРезервноеКопирование() 
	
	ИмяГлавногоФайлаСкрипта = СформироватьФайлыСкриптаОбновления();
	ЖурналРегистрацииКлиент.ДобавитьСообщениеДляЖурналаРегистрации(РезервноеКопированиеИБКлиент.СобытиеЖурналаРегистрации(), 
		"Информация",
		НСтр("ru = 'Выполняется восстановление данных информационной базы:'") + " " + ИмяГлавногоФайлаСкрипта);
	
	ЗакрытьФормуБезусловно = Истина;
	Закрыть();
	
	ПропуститьПредупреждениеПередЗавершениемРаботыСистемы = Истина;
	ЗавершитьРаботуСистемы(Ложь);
	ЗапуститьПриложение("""" + ИмяГлавногоФайлаСкрипта + """",	РезервноеКопированиеИБКлиент.ПолучитьКаталогФайла(ИмяГлавногоФайлаСкрипта));
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции подготовки восстановления данных

&НаКлиенте
Функция СформироватьФайлыСкриптаОбновления() 
	
	ПараметрыКопирования = РезервноеКопированиеИБКлиент.КлиентскиеПараметрыРезервногоКопирования();
	ПараметрыРаботыКлиента = СтандартныеПодсистемыКлиентПовтИсп.ПараметрыРаботыКлиента();
	СоздатьКаталог(ПараметрыКопирования.КаталогВременныхФайловОбновления);
	
	// Структура параметров необходима для их определения на клиенте и передачи на сервер
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("ИмяФайлаПрограммы"			, ПараметрыКопирования.ИмяФайлаПрограммы);
	СтруктураПараметров.Вставить("СобытиеЖурналаРегистрации"	, ПараметрыКопирования.СобытиеЖурналаРегистрации);
	СтруктураПараметров.Вставить("ИмяCOMСоединителя"			, ПараметрыРаботыКлиента.ИмяCOMСоединителя);
	СтруктураПараметров.Вставить("ЭтоБазоваяВерсияКонфигурации"	, ПараметрыРаботыКлиента.ЭтоБазоваяВерсияКонфигурации);
	СтруктураПараметров.Вставить("ИнформационнаяБазаФайловая"	, ПараметрыРаботыКлиента.ИнформационнаяБазаФайловая);
	СтруктураПараметров.Вставить("ПараметрыСкрипта"				, ПараметрыАутентификацииАдминистратораОбновления());
	
	ИменаМакетов = "ДопФайлРезервногоКопирования";
	ИменаМакетов = ИменаМакетов + ",ЗаставкаВосстановления";
	
	ТекстыМакетов = ПолучитьТекстыМакетов(ИменаМакетов, СтруктураПараметров, СообщенияДляЖурналаРегистрации);
	
	ФайлСкрипта = Новый ТекстовыйДокумент;
	ФайлСкрипта.Вывод = ИспользованиеВывода.Разрешить;
	ФайлСкрипта.УстановитьТекст(ТекстыМакетов[0]);
	
	ИмяФайлаСкрипта = ПараметрыКопирования.КаталогВременныхФайловОбновления + "main.js";
	ФайлСкрипта.Записать(ИмяФайлаСкрипта, КодировкаТекста.UTF16);
	
	// Вспомогательный файл: helpers.js
	ФайлСкрипта = Новый ТекстовыйДокумент;
	ФайлСкрипта.Вывод = ИспользованиеВывода.Разрешить;
	ФайлСкрипта.УстановитьТекст(ТекстыМакетов[1]);
	ФайлСкрипта.Записать(ПараметрыКопирования.КаталогВременныхФайловОбновления + "helpers.js", КодировкаТекста.UTF16);
	
	ИмяГлавногоФайлаСкрипта = Неопределено;
	// Вспомогательный файл: splash.png
	БиблиотекаКартинок.ЗаставкаВнешнейОперации.Записать(ПараметрыКопирования.КаталогВременныхФайловОбновления + "splash.png");
	// Вспомогательный файл: splash.ico
	БиблиотекаКартинок.ЗначокЗаставкиВнешнейОперации.Записать(ПараметрыКопирования.КаталогВременныхФайловОбновления + "splash.ico");
	// Вспомогательный файл: progress.gif
	БиблиотекаКартинок.ДлительнаяОперация48.Записать(ПараметрыКопирования.КаталогВременныхФайловОбновления + "progress.gif");
	// Главный файл заставки: splash.hta
	ИмяГлавногоФайлаСкрипта = ПараметрыКопирования.КаталогВременныхФайловОбновления + "splash.hta";
	ФайлСкрипта = Новый ТекстовыйДокумент;
	ФайлСкрипта.Вывод = ИспользованиеВывода.Разрешить;
	ФайлСкрипта.УстановитьТекст(ТекстыМакетов[2]);
	ФайлСкрипта.Записать(ИмяГлавногоФайлаСкрипта, КодировкаТекста.UTF16);
	
	Возврат ИмяГлавногоФайлаСкрипта;
	
КонецФункции

&НаКлиенте
Функция ПараметрыАутентификацииАдминистратораОбновления() 
	
	Результат = Новый Структура("ИмяПользователя,
	|ПарольПользователя,
	|СтрокаПодключения,
	|ПараметрыАутентификации,
	|СтрокаСоединенияИнформационнойБазы",
	Неопределено, "", "", "", "", "");
	
	ТекущиеСоединения = СтрокаСоединенияИИнформацияОСоединениях(СообщенияДляЖурналаРегистрации);
	Результат.СтрокаСоединенияИнформационнойБазы = ТекущиеСоединения.СтрокаСоединенияИнформационнойБазы;
	// Диагностика случая, когда ролевой безопасности в системе не предусмотрено.
	// Т.е. ситуация, когда любой пользователь «может» в системе все.
	Если НЕ ТекущиеСоединения.ЕстьАктивныеПользователи Тогда
		Возврат Результат;
	КонецЕсли;
	
	Пользователь = СтандартныеПодсистемыКлиентПовтИсп.ПараметрыРаботыКлиента().ИнформацияОПользователе.Имя;
	
	Результат.ИмяПользователя			= Пользователь;
	Результат.ПарольПользователя		= ПарольАдминистратораИБ;
	Результат.СтрокаПодключения			= "Usr=""" + Пользователь + """;Pwd=""" + ПарольАдминистратораИБ + """;";
	Результат.ПараметрыАутентификации	= "/N""" + Пользователь + """ /P""" + ПарольАдминистратораИБ + """ /WA-";
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция ПолучитьТекстыМакетов(ИменаМакетов, СтруктураПараметров, СообщенияДляЖурналаРегистрации)
	
	// запись накопленных событий ЖР
	
	ЖурналРегистрации.ЗаписатьСобытияВЖурналРегистрации(СообщенияДляЖурналаРегистрации);
	
	Результат = Новый Массив();
	Результат.Добавить(ПолучитьТекстСкрипта(СтруктураПараметров));
	
	ИменаМакетовМассив = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(ИменаМакетов);
	Для каждого ИмяМакета ИЗ ИменаМакетовМассив Цикл
		Результат.Добавить(Обработки.РезервноеКопированиеИБ.ПолучитьМакет(ИмяМакета).ПолучитьТекст());
	КонецЦикла;
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция ПолучитьТекстСкрипта(СтруктураПараметров)
	
	// Файл обновления конфигурации: main.js
	ШаблонСкрипта = Обработки.РезервноеКопированиеИБ.ПолучитьМакет("МакетФайлаЗагрузкаИБ");
	
	Скрипт = ШаблонСкрипта.ПолучитьОбласть("ОбластьПараметров");
	Скрипт.УдалитьСтроку(1);
	Скрипт.УдалитьСтроку(Скрипт.КоличествоСтрок());
	
	Текст = ШаблонСкрипта.ПолучитьОбласть("ОбластьРезервногоКопирования");
	Текст.УдалитьСтроку(1);
	Текст.УдалитьСтроку(Текст.КоличествоСтрок());
	
	Возврат ВставитьПараметрыСкрипта(Скрипт.ПолучитьТекст(), СтруктураПараметров) + Текст.ПолучитьТекст();
	
КонецФункции

&НаСервере
Функция ВставитьПараметрыСкрипта(Знач Текст, Знач СтруктураПараметров)
	
	Результат = Текст;
	
	ИменаФайловОбновления = "";
	ИменаФайловОбновления = "[" + "" + "]";
	
	СтрокаСоединенияИнформационнойБазы = СтруктураПараметров.ПараметрыСкрипта.СтрокаСоединенияИнформационнойБазы +
	СтруктураПараметров.ПараметрыСкрипта.СтрокаПодключения; 
	
	ИмяИсполняемогоФайлаПрограммы = КаталогПрограммы() + СтруктураПараметров.ИмяФайлаПрограммы;
	ИмяФайлаЗапускаПриложенияВРежимеПредприятия = КаталогПрограммы() + ИмяФайлаЗапускаПриложенияВРежимеПредприятия;
	
	// Определение пути к информационной базе.
	ПризнакФайловогоРежима = Неопределено;
	ПутьКИнформационнойБазе = СоединенияИБКлиентСервер.ПутьКИнформационнойБазе(ПризнакФайловогоРежима, 0);
	
	ПараметрПутиКИнформационнойБазе = ?(ПризнакФайловогоРежима, "/F", "/S") + ПутьКИнформационнойБазе; 
	СтрокаПутиКИнформационнойБазе	= ?(ПризнакФайловогоРежима, ПутьКИнформационнойБазе, "");
	
	Результат = СтрЗаменить(Результат, "[ИменаФайловОбновления]"				, ИменаФайловОбновления);
	Результат = СтрЗаменить(Результат, "[ИмяИсполняемогоФайлаПрограммы]"		, ПодготовитьТекст(ИмяИсполняемогоФайлаПрограммы));
	Результат = СтрЗаменить(Результат, "[ИмяФайлаЗапускаПриложенияВРежимеПредприятия]", ПодготовитьТекст(ИмяФайлаЗапускаПриложенияВРежимеПредприятия));
	Результат = СтрЗаменить(Результат, "[ПараметрПутиКИнформационнойБазе]"		, ПодготовитьТекст(ПараметрПутиКИнформационнойБазе));
	Результат = СтрЗаменить(Результат, "[СтрокаПутиКФайлуИнформационнойБазы]"	, ПодготовитьТекст(ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(СтрЗаменить(СтрокаПутиКИнформационнойБазе, """", "")))); 
	Результат = СтрЗаменить(Результат, "[СтрокаПутиКФайлуИнформационнойБазы2]"	, ПодготовитьТекст("1Cv8.1CD"));
	Результат = СтрЗаменить(Результат, "[СтрокаСоединенияИнформационнойБазы]"	, ПодготовитьТекст(СтрокаСоединенияИнформационнойБазы));
	Результат = СтрЗаменить(Результат, "[ПараметрыАутентификацииПользователя]"	, ПодготовитьТекст(СтруктураПараметров.ПараметрыСкрипта.ПараметрыАутентификации));
	Результат = СтрЗаменить(Результат, "[СобытиеЖурналаРегистрации]"			, ПодготовитьТекст(СтруктураПараметров.СобытиеЖурналаРегистрации));
	Результат = СтрЗаменить(Результат, "[АдресЭлектроннойПочты]", 
	"");
	Результат = СтрЗаменить(Результат, "[ИмяАдминистратораОбновления]"			, ПодготовитьТекст(ИмяПользователя()));
	Результат = СтрЗаменить(Результат, "[СоздаватьРезервнуюКопию]"				,"true");
	
	Результат = СтрЗаменить(Результат, "[КаталогРезервнойКопии]",ПодготовитьТекст(Объект.ФайлЗагрузкиРезервнойКопии));
	СтрокаКаталога = ПроверитьКаталогНаУказаниеКорневогоЭлемента(Объект.КаталогСРезервнымиКопиями);
	
	Результат = СтрЗаменить(Результат, "[КаталогРезервнойКопии2]"				,ПодготовитьТекст(СтрокаКаталога+"\backup"+СтрокаКаталогаИзДаты()));
	Результат = СтрЗаменить(Результат, "[ВосстанавливатьИнформационнуюБазу]"	, "false");
	Результат = СтрЗаменить(Результат, "[БлокироватьСоединенияИБ]"				, ?(СтруктураПараметров.ИнформационнаяБазаФайловая, "false", "true"));
	Результат = СтрЗаменить(Результат, "[ИмяCOMСоединителя]"					, ПодготовитьТекст(СтруктураПараметров.ИмяCOMСоединителя));
	Результат = СтрЗаменить(Результат, "[ИспользоватьCOMСоединитель]"			, ?(СтруктураПараметров.ЭтоБазоваяВерсияКонфигурации, "false", "true"));
	Результат = СтрЗаменить(Результат, "[КаталогВременныхФайлов]"				, ПодготовитьТекст(КаталогВременныхФайлов()));
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция ПроверитьКаталогНаУказаниеКорневогоЭлемента(СтрокаКаталога)
	
	Если Прав(СтрокаКаталога, 2) = ":\" Тогда
		Возврат Лев(СтрокаКаталога, СтрДлина(СтрокаКаталога) - 1) ;
	Иначе
		Возврат СтрокаКаталога;
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция СтрокаКаталогаИзДаты()
	
	СтрокаВозврата = "";
	ДатаСейчас = ТекущаяДатаСеанса();
	СтрокаВозврата = Формат(ДатаСейчас, "ДФ = гггг_ММ_дд_ЧЧ_мм_сс");
	Возврат СтрокаВозврата;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПодготовитьТекст(Знач Текст)
	
	Возврат "'" + СтрЗаменить(Текст, "\", "\\") + "'";
	
КонецФункции

&НаСервере
Функция СтрокаСоединенияИИнформацияОСоединениях(СообщенияДляЖурналаРегистрации)
	
	// запись накопленных событий ЖР
	ЖурналРегистрации.ЗаписатьСобытияВЖурналРегистрации(СообщенияДляЖурналаРегистрации);
	Результат = ИнформацияОНаличииСоединений();
	Результат.Вставить("СтрокаСоединенияИнформационнойБазы", 
		СоединенияИБКлиентСервер.ПолучитьСтрокуСоединенияИнформационнойБазы(0));
	Возврат Результат;
	
КонецФункции

&НаСервереБезКонтекста
Функция ИнформацияОНаличииСоединений(СообщенияДляЖурналаРегистрации = Неопределено)
	
	ЖурналРегистрации.ЗаписатьСобытияВЖурналРегистрации(СообщенияДляЖурналаРегистрации);
	УстановитьПривилегированныйРежим(Истина);
	Результат = Новый Структура("НаличиеАктивныхСоединений, НаличиеCOMСоединений, НаличиеСоединенияКонфигуратором, ЕстьАктивныеПользователи",
		Ложь,
		Ложь,
		Ложь,
		Ложь);
	
	Если ПользователиИнформационнойБазы.ПолучитьПользователей().Количество() > 0 Тогда 
		Результат.ЕстьАктивныеПользователи = Истина;
	КонецЕсли;
	
	МассивСеансов = ПолучитьСеансыИнформационнойБазы();
	Если МассивСеансов.Количество() = 1 Тогда 
		Возврат Результат;
	КонецЕсли;
	
	Результат.НаличиеАктивныхСоединений = Истина;
	
	Для Каждого Сеанс Из МассивСеансов Цикл
		Если ЭтоCOMСоединение(Сеанс) Тогда 
			Результат.НаличиеCOMСоединений = Истина;
		ИначеЕсли ЭтоСеансКонфигуратора(Сеанс) Тогда 
			Результат.НаличиеСоединенияКонфигуратором = Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

&НаСервереБезКонтекста
Функция ЭтоСеансКонфигуратора(СеансИнформационнойБазы)
	
	Возврат ВРег(СеансИнформационнойБазы.ИмяПриложения) = ВРег("Designer");
	
КонецФункции 

&НаСервереБезКонтекста
Функция ЭтоCOMСоединение(СеансИнформационнойБазы)
	
	Возврат ВРег(СеансИнформационнойБазы.ИмяПриложения) = ВРег("COMConnection");
	
КонецФункции

&НаСервере
Процедура УстановитьПараметрыРезервногоКопирования()
	
	ПараметрыРезервногоКопирования = РезервноеКопированиеИБСервер.НастройкиРезервногоКопирования();
	
	ПараметрыРезервногоКопирования.Вставить("АдминистраторИБ", АдминистраторИБ);
	ПараметрыРезервногоКопирования.Вставить("ПарольАдминистратораИБ", ?(ТребуетсяВводПароля, ПарольАдминистратораИБ, ""));
	
	РезервноеКопированиеИБСервер.УстановитьПараметрыРезервногоКопирования(ПараметрыРезервногоКопирования);
	
КонецПроцедуры

#КонецОбласти
