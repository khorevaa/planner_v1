﻿////////////////////////////////////////////////////////////////////////////////
// Подсистема "Информация при запуске"
//
////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Добавление обработчиков служебных событий (подписок)

// См. описание этой же процедуры в модуле СтандартныеПодсистемыСервер.
Процедура ПриДобавленииОбработчиковСлужебныхСобытий(КлиентскиеОбработчики, СерверныеОбработчики) Экспорт
	
	// КЛИЕНТСКИЕ ОБРАБОТЧИКИ.
	
	КлиентскиеОбработчики["СтандартныеПодсистемы.БазоваяФункциональность\ПриНачалеРаботыСистемы"].Добавить(
		"ИнформацияПриЗапускеКлиент");
	
	// СЕРВЕРНЫЕ ОБРАБОТЧИКИ.
	
	СерверныеОбработчики["СтандартныеПодсистемы.ОбновлениеВерсииИБ\ПослеОбновленияИнформационнойБазы"].Добавить(
		"ИнформацияПриЗапуске");
	
	СерверныеОбработчики["СтандартныеПодсистемы.БазоваяФункциональность\ПриДобавленииПараметровРаботыКлиентскойЛогикиСтандартныхПодсистемПриЗапуске"].Добавить(
		"ИнформацияПриЗапуске");
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики служебных событий

// Вызывается после завершения монопольного обновления данных ИБ.
//
// Параметры:
//   ПредыдущаяВерсия       - Строка - версия подсистемы до обновления. "0.0.0.0" для "пустой" ИБ.
//   ТекущаяВерсия          - Строка - версия подсистемы после обновления.
//   ВыполненныеОбработчики - ДеревоЗначений - список выполненных процедур-обработчиков обновления
//                                             подсистемы, сгруппированных по номеру версии.
//                            Процедура обхода выполненных обработчиков:
//
//	Для Каждого Версия Из ВыполненныеОбработчики.Строки Цикл
//		
//		Если Версия.Версия = "*" Тогда
//			// Обработчик, который может выполнятся при каждой смене версии.
//		Иначе
//			// Обработчик, который выполняется для определенной версии.
//		КонецЕсли;
//		
//		Для Каждого Обработчик Из Версия.Строки Цикл
//			...
//		КонецЦикла;
//		
//	КонецЦикла;
//
//   ВыводитьОписаниеОбновлений - Булево (возвращаемое значение)- если установить Истина,
//                                тогда выводить форму с описанием обновлений.
//   МонопольныйРежим           - Булево - признак выполнения обновления в монопольном режиме.
//                                Истина - обновление выполнялось в монопольном режиме.
//
Процедура ПослеОбновленияИнформационнойБазы(Знач ПредыдущаяВерсия, Знач ТекущаяВерсия,
		Знач ВыполненныеОбработчики, ВыводитьОписаниеОбновлений, МонопольныйРежим) Экспорт
	
	ОбщегоНазначения.ХранилищеОбщихНастроекУдалить("ИнформацияПриЗапуске", Неопределено, Неопределено);
	
КонецПроцедуры

// Заполняет параметры, которые используется клиентским кодом на запуске конфигурации.
//
// Параметры:
//   Параметры - Структура - Параметры запуска.
//
Процедура ПриДобавленииПараметровРаботыКлиентскойЛогикиСтандартныхПодсистемПриЗапуске(Параметры) Экспорт
	Настройки = Новый Структура;
	Настройки.Вставить("Показывать", Ложь);
	Если Метаданные.Обработки.ИнформацияПриЗапуске.Макеты.Количество() > 1 Тогда
		Если СтандартныеПодсистемыСервер.ЭтоБазоваяВерсияКонфигурации() Тогда
			Настройки.Показывать = Истина;
		Иначе
			Настройки.Показывать = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("ИнформацияПриЗапуске", "Показывать", Истина);
			Если Не Настройки.Показывать Тогда
				ДатаБлижайшегоПоказа = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("ИнформацияПриЗапуске", "ДатаБлижайшегоПоказа");
				Если ДатаБлижайшегоПоказа = Неопределено Или ДатаБлижайшегоПоказа <= ТекущаяДатаСеанса() Тогда
					Настройки.Показывать = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	ИнформацияПриЗапускеПереопределяемый.ОпределитьНастройки(Настройки);
	
	Параметры.Вставить("ИнформацияПриЗапуске", Новый ФиксированнаяСтруктура(Настройки));
КонецПроцедуры

#КонецОбласти
