﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Если Параметры.РежимВыбора Тогда
		Элементы.Список.РежимВыбора = Истина;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы
//

&НаКлиенте
Процедура ОбъединитьВыделенные(Команда)
	
	СтандартныеПодсистемыКлиент.ОбъединитьВыделенные(Элементы.Список);
	
КонецПроцедуры

#КонецОбласти
