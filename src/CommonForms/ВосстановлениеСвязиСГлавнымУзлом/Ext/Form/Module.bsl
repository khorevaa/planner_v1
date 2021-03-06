﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	ГлавныйУзел = Константы.ГлавныйУзел.Получить();
	
	Если Не ЗначениеЗаполнено(ГлавныйУзел) Тогда
		ВызватьИсключение НСтр("ru = 'Главный узел не сохранен.'");
	КонецЕсли;
	
	Если ПланыОбмена.ГлавныйУзел() <> Неопределено Тогда
		ВызватьИсключение НСтр("ru = 'Главный узел установлен.'");
	КонецЕсли;
	
	Элементы.ТекстПредупреждения.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		Элементы.ТекстПредупреждения.Заголовок, Строка(ГлавныйУзел));
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Восстановить(Команда)
	
	ВосстановитьНаСервере();
	
	Закрыть(Новый Структура("Отказ", Ложь));
	
КонецПроцедуры

&НаКлиенте
Процедура Отключить(Команда)
	
	ОтключитьНаСервере();
	
	Закрыть(Новый Структура("Отказ", Ложь));
	
КонецПроцедуры

&НаКлиенте
Процедура ЗавершитьРаботу(Команда)
	
	Закрыть(Новый Структура("Отказ", Истина));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Процедура ОтключитьНаСервере()
	
	ГлавныйУзелМенеджер = Константы.ГлавныйУзел.СоздатьМенеджерЗначения();
	ГлавныйУзелМенеджер.Значение = Неопределено;
	ОбновлениеИнформационнойБазы.ЗаписатьДанные(ГлавныйУзелМенеджер);
	
	УстановитьИнициализациюВсехСуществующихПредопределенныхДанных();
	
	УстановитьОбновлениеПредопределенныхДанныхИнформационнойБазы(
		ОбновлениеПредопределенныхДанных.Авто);
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ВосстановитьНаСервере()
	
	ГлавныйУзел = Константы.ГлавныйУзел.Получить();
	
	ПланыОбмена.УстановитьГлавныйУзел(ГлавныйУзел);
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура УстановитьИнициализациюВсехСуществующихПредопределенныхДанных()
	
	КоллекцииМетаданных = Новый Массив;
	КоллекцииМетаданных.Добавить(Метаданные.Справочники);
	КоллекцииМетаданных.Добавить(Метаданные.ПланыВидовХарактеристик);
	КоллекцииМетаданных.Добавить(Метаданные.ПланыСчетов);
	КоллекцииМетаданных.Добавить(Метаданные.ПланыВидовРасчета);
	
	Запрос = Новый Запрос;
	ТекстЗапроса =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ИСТИНА КАК ЗначениеИстина
	|ИЗ
	|	&ТекущаяТаблица КАК ПсевдонимЗаданнойТаблицы
	|ГДЕ
	|	ПсевдонимЗаданнойТаблицы.Предопределенный";
	
	Для каждого Коллекция Из КоллекцииМетаданных Цикл
		Для Каждого ОбъектМетаданных Из Коллекция Цикл
			ПолноеИмя = ОбъектМетаданных.ПолноеИмя();
			Запрос.Текст = СтрЗаменить(ТекстЗапроса, "&ТекущаяТаблица", ПолноеИмя);
			Если Запрос.Выполнить().Пустой() Тогда
				Продолжить;
			КонецЕсли;
			Менеджер = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(ПолноеИмя);
			Менеджер.УстановитьОбновлениеПредопределенныхДанных(ОбновлениеПредопределенныхДанных.НеОбновлятьАвтоматически);
			Менеджер.УстановитьОбновлениеПредопределенныхДанных(ОбновлениеПредопределенныхДанных.Авто);
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
