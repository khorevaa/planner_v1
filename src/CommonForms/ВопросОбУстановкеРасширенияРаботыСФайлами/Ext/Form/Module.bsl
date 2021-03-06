﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	Если Не ПустаяСтрока(Параметры.ТекстПредложения) Тогда
		Элементы.ДекорацияПояснение.Заголовок = Параметры.ТекстПредложения
			+ Символы.ПС
			+ НСтр("ru = 'Установить?'");
		
	ИначеЕсли Не Параметры.ВозможноПродолжениеБезУстановки Тогда
		Элементы.ДекорацияПояснение.Заголовок =
			НСтр("ru = 'Для выполнения действия требуется установить расширение для веб-клиента 1С:Предприятие.
			           |Установить?'");
	КонецЕсли;
	
	Если Не Параметры.ВозможноПродолжениеБезУстановки Тогда
		Элементы.ПродолжитьБезУстановки.Заголовок = НСтр("ru = 'Отмена'");
		Элементы.БольшеНеНапоминать.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура УстановитьИПродолжить(Команда)
	
	Оповещение = Новый ОписаниеОповещения("УстановитьИПродолжитьЗавершение", ЭтотОбъект);
	НачатьУстановкуРасширенияРаботыСФайлами(Оповещение);
	
КонецПроцедуры

&НаКлиенте
Процедура ПродолжитьБезУстановки(Команда)
	Закрыть("ПродолжитьБезУстановки");
КонецПроцедуры

&НаКлиенте
Процедура БольшеНеНапоминать(Команда)
	Закрыть("БольшеНеПредлагать");
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура УстановитьИПродолжитьЗавершение(ДополнительныеПараметры) Экспорт
	
	Закрыть(?(ПодключитьРасширениеРаботыСФайлами(), "БольшеНеПредлагать", "ПродолжитьБезУстановки"));
	
КонецПроцедуры

#КонецОбласти
