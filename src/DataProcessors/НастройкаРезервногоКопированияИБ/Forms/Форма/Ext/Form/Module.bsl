﻿&НаКлиенте
Перем ЗаписатьНастройки, МинимальнаяДатаСледующегоАвтоматическогоРезервногоКопирования;

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
	
	НастройкиРезервногоКопирования = РезервноеКопированиеИБСервер.НастройкиРезервногоКопирования();
	
	Объект.ВариантВыполнения = НастройкиРезервногоКопирования.ВариантВыполнения;
	Объект.ВыполнятьАвтоматическоеРезервноеКопирование = НастройкиРезервногоКопирования.ВыполнятьАвтоматическоеРезервноеКопирование;
	Объект.РезервноеКопированиеНастроено = НастройкиРезервногоКопирования.РезервноеКопированиеНастроено;
	
	Если Не Объект.РезервноеКопированиеНастроено Тогда
		
		Объект.ВыполнятьАвтоматическоеРезервноеКопирование = Истина;
		
	КонецЕсли;
	
	ПарольАдминистратораИБ = НастройкиРезервногоКопирования.ПарольАдминистратораИБ;
	Расписание = ОбщегоНазначенияКлиентСервер.СтруктураВРасписание(НастройкиРезервногоКопирования.РасписаниеКопирования);
	Элементы.ИзменитьРасписание.Заголовок = Строка(Расписание);
	Объект.КаталогСРезервнымиКопиями = НастройкиРезервногоКопирования.КаталогХраненияРезервныхКопий;
	
	// Заполнение настроек по хранению старых копий.
	
	ЗаполнитьЗначенияСвойств(Объект, НастройкиРезервногоКопирования.ПараметрыУдаления);
	
	ОбновитьТипОграниченияКаталогаСРезервнымиКопиями(ЭтотОбъект);
	
	// Первая часть проверки на сервере - если в информационной базе есть пользователи
	ТребуетсяВводПароля = (ПользователиИнформационнойБазы.ПолучитьПользователей().Количество() > 0);
	
	Элементы.ИзменитьРасписание.Доступность = (Объект.ВариантВыполнения = "ПоРасписанию");
	Элементы.ГруппаПараметры.Доступность = Объект.ВыполнятьАвтоматическоеРезервноеКопирование;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ОбщегоНазначенияКлиентСервер.ЭтоLinuxКлиент() Тогда
		Отказ = Истина;
		ТекстСообщения = НСтр("ru = 'Резервное копирование не поддерживается в клиенте под управлением ОС Linux.'");
		ПоказатьПредупреждение(, ТекстСообщения);
		Возврат;
	КонецЕсли;
	
	МинимальнаяДатаСледующегоАвтоматическогоРезервногоКопирования = ПараметрыРезервногоКопированияИБ.МинимальнаяДатаСледующегоАвтоматическогоРезервногоКопирования;
	ПараметрыРезервногоКопированияИБ.МинимальнаяДатаСледующегоАвтоматическогоРезервногоКопирования = '29990101';
	ЗаписатьНастройки = Ложь;
	
	ИнформацияОПользователе = СтандартныеПодсистемыКлиентПовтИсп.ПараметрыРаботыКлиента().ИнформацияОПользователе;
	
	// Вторая часть проверки на клиенте - если у текущего пользователя (администратор)
	// используется стандартная аутентификация и установлен пароль
	ТребуетсяВводПароля = ТребуетсяВводПароля И ИнформацияОПользователе.АутентификацияСтандартная И ИнформацияОПользователе.ПарольУстановлен;
	
	Если ТребуетсяВводПароля Тогда
		АдминистраторИБ = ИнформацияОПользователе.Имя;
	Иначе
		Элементы.ГруппаАвторизации.Видимость = Ложь;
		Элементы.АвторизацияАдминистратораИнформационнойБазы.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	
	Если Не ЗаписатьНастройки Тогда
		ПараметрыРезервногоКопированияИБ.МинимальнаяДатаСледующегоАвтоматическогоРезервногоКопирования = МинимальнаяДатаСледующегоАвтоматическогоРезервногоКопирования;
	КонецЕсли;
	
	Оповестить("ЗакрытаФормаНастройкиРезервногоКопирования");
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ТипОграниченияКаталогаСРезервнымиКопиямиПриИзменении(Элемент)
	
	
	ОбновитьТипОграниченияКаталогаСРезервнымиКопиями(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПутьККаталогуАрхивовНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ВыбранныйПуть = ПолучитьПуть(РежимДиалогаВыбораФайла.ВыборКаталога);
	Если Не ПустаяСтрока(ВыбранныйПуть) Тогда 
		Объект.КаталогСРезервнымиКопиями = ВыбранныйПуть;
	КонецЕсли;
	
КонецПроцедуры

// Обработчик перехода к журналу регистрации.
&НаКлиенте
Процедура НадписьПерейтиВЖурналРегистрацииНажатие(Элемент)
	ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.ЖурналРегистрации", , ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ВариантПроведенияРезервногоКопированияПриИзменении(Элемент)
	
	Элементы.ИзменитьРасписание.Доступность = (Объект.ВариантВыполнения = "ПоРасписанию");
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Готово(Команда)
	
	ЗаписатьНастройки = Истина;
	ПерейтиСоСтраницыНастройки();
	
КонецПроцедуры

// Вызывает стандартную форму настройки расписания регламентного задания, 
// заполняя его текущими настройками расписания резервного копирования.
&НаКлиенте
Процедура ИзменитьРасписание(Команда)
	
	ДиалогРасписания = Новый ДиалогРасписанияРегламентногоЗадания(Расписание);
	ОписаниеОповещения = Новый ОписаниеОповещения("ИзменитьРасписаниеЗавершение", ЭтотОбъект);
	ДиалогРасписания.Показать(ОписаниеОповещения);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПерейтиСоСтраницыНастройки()
	
	Если Объект.ВыполнятьАвтоматическоеРезервноеКопирование Тогда
		
		Если Не ПроверитьКаталогСРезервнымиКопиями() Тогда
			Возврат;
		КонецЕсли;
		
		Если Не ПроверитьДоступКИБ() Тогда
			Элементы.СтраницыПомощника.ТекущаяСтраница = Элементы.ДополнительныеНастройки;
			Возврат;
		КонецЕсли;
		
		ЗаписатьНастройки();
		
		Если Объект.ВариантВыполнения = "ПоРасписанию" Тогда
			
			ТекущаяДата = ОбщегоНазначенияКлиент.ДатаСеанса();
			ПараметрыРезервногоКопированияИБ.МинимальнаяДатаСледующегоАвтоматическогоРезервногоКопирования = ТекущаяДата;
			ПараметрыРезервногоКопированияИБ.ДатаПоследнегоРезервногоКопирования = ТекущаяДата;
			ПараметрыРезервногоКопированияИБ.РасписаниеЗначение = Расписание;
			
		ИначеЕсли Объект.ВариантВыполнения = "ПриЗавершенииРаботы" Тогда
			
			ПараметрыРезервногоКопированияИБ.МинимальнаяДатаСледующегоАвтоматическогоРезервногоКопирования = '29990101';
			
		КонецЕсли;
		
		ИмяФормыНастроек = "e1cib/app/%1";
		ИмяФормыНастроек = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ИмяФормыНастроек,
		РезервноеКопированиеИБКлиент.ИмяФормыНастроекРезервногоКопирования());
		
		ПоказатьОповещениеПользователя(НСтр("ru = 'Резервное копирование'"), ИмяФормыНастроек,
		НСтр("ru = 'Резервное копирование настроено.'"));
		
	Иначе
		
		ОстановитьСервисОповещения();
		ПараметрыРезервногоКопированияИБ.МинимальнаяДатаСледующегоАвтоматическогоРезервногоКопирования = '29990101';
		
	КонецЕсли;
	
	ПараметрыРезервногоКопированияИБ.ПараметрОповещения = "НеОповещать";
	
	ОбновитьПовторноИспользуемыеЗначения();
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Функция ПроверитьКаталогСРезервнымиКопиями()
	
	РеквизитыЗаполнены = Истина;
	
	Если ПустаяСтрока(Объект.КаталогСРезервнымиКопиями) Тогда
		
		ТекстСообщения = Нстр("ru = 'Не выбран каталог для резервной копии.'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "Объект.КаталогСРезервнымиКопиями");
		РеквизитыЗаполнены = Ложь;
		
	ИначеЕсли НайтиФайлы(Объект.КаталогСРезервнымиКопиями).Количество() = 0 Тогда
		
		ТекстСообщения = Нстр("ru = 'Указан несуществующий каталог.'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "Объект.КаталогСРезервнымиКопиями");
		РеквизитыЗаполнены = Ложь;
		
	Иначе
		
		Попытка
			ТестовыйФайл = Новый ЗаписьXML;
			ТестовыйФайл.ОткрытьФайл(Объект.КаталогСРезервнымиКопиями + "/test.test1С");
			ТестовыйФайл.ЗаписатьОбъявлениеXML();
			ТестовыйФайл.Закрыть();
		Исключение
			ТекстСообщения = Нстр("ru = 'Нет доступа к каталогу с резервными копиями.'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "Объект.КаталогСРезервнымиКопиями");
			РеквизитыЗаполнены = Ложь;
		КонецПопытки;
		
		Если РеквизитыЗаполнены Тогда
			
			Попытка
				УдалитьФайлы(Объект.КаталогСРезервнымиКопиями, "*.test1С");
			Исключение
				// Исключение не обрабатываем т.к. на этом шаге не происходит удаления файлов
			КонецПопытки;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если ТребуетсяВводПароля И ПустаяСтрока(ПарольАдминистратораИБ) Тогда
		
		ТекстСообщения = НСтр("ru = 'Не задан пароль администратора.'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, "ПарольАдминистратораИБ");
		РеквизитыЗаполнены = Ложь;
		
	КонецЕсли;
	
	Возврат РеквизитыЗаполнены;
	
КонецФункции

// Запрашивает у пользователя путь к файлу или каталогу.
&НаКлиенте
Функция ПолучитьПуть(РежимДиалога)
	
	Режим = РежимДиалога;
	ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(Режим);
	
	Если Режим = РежимДиалогаВыбораФайла.ВыборКаталога Тогда
		ДиалогОткрытияФайла.Заголовок= НСтр("ru = 'Выберите каталог'");
	Иначе
		ДиалогОткрытияФайла.Заголовок= НСтр("ru = 'Выберите файл'");
	КонецЕсли;	
		
	Если ДиалогОткрытияФайла.Выбрать() Тогда
		Если РежимДиалога = РежимДиалогаВыбораФайла.ВыборКаталога тогда
			Возврат ДиалогОткрытияФайла.Каталог;
		Иначе
			Возврат ДиалогОткрытияФайла.ПолноеИмяФайла;
		КонецЕсли;
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Функция ПроверитьДоступКИБ()

	Результат = Истина;
	// В базовых версиях проверку подключения не осуществляем;
	// при некорректном вводе имени и пароля обновление завершится неуспешно.
	Если СтандартныеПодсистемыКлиентПовтИсп.ПараметрыРаботыКлиента().ЭтоБазоваяВерсияКонфигурации Тогда
		Возврат Результат;
	КонецЕсли; 
	ПараметрыПодключения = ПолучитьПараметрыАутентификацииАдминистратораОбновления();
	ОбщегоНазначенияКлиент.ЗарегистрироватьCOMСоединитель(Ложь);
	
	Попытка
		ComConnector = Новый COMОбъект(СтандартныеПодсистемыКлиентПовтИсп.ПараметрыРаботыКлиента().ИмяCOMСоединителя);
		СтрокаСоединенияИнформационнойБазы = ПараметрыПодключения.СтрокаСоединенияИнформационнойБазы + ПараметрыПодключения.СтрокаПодключения;
		Соединение = ComConnector.Connect(СтрокаСоединенияИнформационнойБазы);
	Исключение
		Результат = Ложь;
		Инфо = ИнформацияОбОшибке();
		ОбнаруженнаяОшибкаПодключения = КраткоеПредставлениеОшибки(Инфо);
		
		ЖурналРегистрацииКлиент.ДобавитьСообщениеДляЖурналаРегистрации(
			РезервноеКопированиеИБКлиент.СобытиеЖурналаРегистрации(),"Ошибка", ОбнаруженнаяОшибкаПодключения, , Истина);
			
	КонецПопытки;	
	
	Возврат Результат;
	
КонецФункции

&НаСервереБезКонтекста
Процедура ОстановитьСервисОповещения()
	// Останавливает оповещения о резервном копировании.
	НастройкиРезервногоКопирования = РезервноеКопированиеИБСервер.НастройкиРезервногоКопирования();
	НастройкиРезервногоКопирования.ВыполнятьАвтоматическоеРезервноеКопирование = Ложь;
	НастройкиРезервногоКопирования.РезервноеКопированиеНастроено = Истина;
	НастройкиРезервногоКопирования.МинимальнаяДатаСледующегоАвтоматическогоРезервногоКопирования = '29990101';
	РезервноеКопированиеИБСервер.УстановитьПараметрыРезервногоКопирования(НастройкиРезервногоКопирования);
КонецПроцедуры

&НаСервере
Процедура ЗаписатьНастройки()
	
	ПараметрыРезервногоКопирования = РезервноеКопированиеИБСервер.ПараметрыРезервногоКопирования();
	
	ПараметрыРезервногоКопирования.Вставить("АдминистраторИБ", АдминистраторИБ);
	ПараметрыРезервногоКопирования.Вставить("ПарольАдминистратораИБ", ?(ТребуетсяВводПароля, ПарольАдминистратораИБ, ""));
	ПараметрыРезервногоКопирования.ДатаПоследнегоОповещения = Дата('29990101');
	ПараметрыРезервногоКопирования.КаталогХраненияРезервныхКопий = Объект.КаталогСРезервнымиКопиями;
	ПараметрыРезервногоКопирования.ВариантВыполнения = Объект.ВариантВыполнения;
	ПараметрыРезервногоКопирования.ВыполнятьАвтоматическоеРезервноеКопирование = Объект.ВыполнятьАвтоматическоеРезервноеКопирование;
	ПараметрыРезервногоКопирования.РезервноеКопированиеНастроено = Объект.РезервноеКопированиеНастроено;
	
	ЗаполнитьЗначенияСвойств(ПараметрыРезервногоКопирования.ПараметрыУдаления, Объект);
	
	Если Объект.ВариантВыполнения = "ПоРасписанию" Тогда
		
		РасписаниеСтруктура = ОбщегоНазначенияКлиентСервер.РасписаниеВСтруктуру(Расписание);
		ПараметрыРезервногоКопирования.РасписаниеКопирования = РасписаниеСтруктура;
		
	ИначеЕсли Объект.ВариантВыполнения = "ПриЗавершенииРаботы" Тогда
		
		ПараметрыРезервногоКопирования.МинимальнаяДатаСледующегоАвтоматическогоРезервногоКопирования = '29990101';
		
	КонецЕсли;
	
	РезервноеКопированиеИБСервер.УстановитьПараметрыРезервногоКопирования(ПараметрыРезервногоКопирования);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ОбновитьТипОграниченияКаталогаСРезервнымиКопиями(Форма)
	
	Форма.Элементы.ГруппаВыбораТипаОчистки.Доступность = (Форма.Объект.ТипОграничения <> "ХранитьВсе");
	Форма.Элементы.ГруппаХранитьПоследниеЗаПериод.Доступность = (Форма.Объект.ТипОграничения = "ПоПериоду");
	Форма.Элементы.ГруппаКоличествоКопийВКаталоге.Доступность = (Форма.Объект.ТипОграничения = "ПоКоличеству");
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьРасписаниеЗавершение(РасписаниеРезультат, ДополнительныеПараметры) Экспорт
	
	Если РасписаниеРезультат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Расписание = РасписаниеРезультат;
	Элементы.ИзменитьРасписание.Заголовок = Строка(Расписание);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции проведения резервного копирования

 &НаСервере
Функция ПолучитьСтрокуСоединенияИИнформациюОСоединениях(СообщенияДляЖурналаРегистрации)
	
	// запись накопленных событий ЖР
	ЖурналРегистрации.ЗаписатьСобытияВЖурналРегистрации(СообщенияДляЖурналаРегистрации);
	
	Результат = ПолучитьИнформациюОНаличииСоединений();
	Результат.Вставить("СтрокаСоединенияИнформационнойБазы", 
	СоединенияИБКлиентСервер.ПолучитьСтрокуСоединенияИнформационнойБазы(0));
	
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Функция ПолучитьПараметрыАутентификацииАдминистратораОбновления()
	
	Результат = Новый Структура("ИмяПользователя,
	|ПарольПользователя,
	|СтрокаПодключения,
	|ПараметрыАутентификации,
	|СтрокаСоединенияИнформационнойБазы",
	Неопределено, "", "", "", "", "");
	
	ТекущиеСоединения = ПолучитьСтрокуСоединенияИИнформациюОСоединениях(СообщенияДляЖурналаРегистрации);
	Результат.СтрокаСоединенияИнформационнойБазы = ТекущиеСоединения.СтрокаСоединенияИнформационнойБазы;
	// Диагностика случая, когда ролевой безопасности в системе не предусмотрено.
	// Т.е. ситуация, когда любой пользователь «может» в системе все.
	Если НЕ ТекущиеСоединения.ЕстьАктивныеПользователи Тогда
		Возврат Результат;
	КонецЕсли;
	
	Пользователь = СтандартныеПодсистемыКлиентПовтИсп.ПараметрыРаботыКлиента().ИнформацияОПользователе.Имя;
	ПарольАдминистратора = ?(ТребуетсяВводПароля, ПарольАдминистратораИБ, "");
	
	Результат.ИмяПользователя			= Пользователь;
	Результат.ПарольПользователя		= ПарольАдминистратора;
	Результат.СтрокаПодключения			= "Usr=""" + Пользователь + """;Pwd=""" + ПарольАдминистратора + """;";
	Результат.ПараметрыАутентификации	= "/N""" + Пользователь + """ /P""" + ПарольАдминистратора + """ /WA-";
	Возврат Результат;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьИнформациюОНаличииСоединений(СообщенияДляЖурналаРегистрации = Неопределено)
	
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
		ИначеЕсли ЭтоСеансКонфигуратором(Сеанс) Тогда 
			Результат.НаличиеСоединенияКонфигуратором = Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

&НаСервереБезКонтекста
Функция ЭтоСеансКонфигуратором(СеансИнформационнойБазы)
	
	Возврат ВРег(СеансИнформационнойБазы.ИмяПриложения) = ВРег("Designer");
	
КонецФункции 

&НаСервереБезКонтекста
Функция ЭтоCOMСоединение(СеансИнформационнойБазы)
	
	Возврат ВРег(СеансИнформационнойБазы.ИмяПриложения) = ВРег("COMConnection");
	
КонецФункции 

&НаКлиенте
Процедура ВыполнятьАвтоматическоеРезервноеКопированиеПриИзменении(Элемент)
	
	Элементы.ГруппаПараметры.Доступность = Объект.ВыполнятьАвтоматическоеРезервноеКопирование;
	
КонецПроцедуры

#КонецОбласти
