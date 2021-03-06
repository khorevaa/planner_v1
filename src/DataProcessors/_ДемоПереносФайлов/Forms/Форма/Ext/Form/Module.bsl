﻿&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	МассивПереносимыхОМ = Новый Массив;
	
	Для Каждого ОМСправочник Из Метаданные.Справочники Цикл
		Если Прав(ОМСправочник.Имя, 19) = "ПрисоединенныеФайлы" Тогда
			КраткоеИмяВладельцаФайлов = Лев(ОМСправочник.Имя, СтрДлина(ОМСправочник.Имя)-19);
			Если Метаданные.Справочники.Найти(КраткоеИмяВладельцаФайлов) = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			ИмяТипа = "СправочникСсылка." + КраткоеИмяВладельцаФайлов;
			Если Метаданные.Справочники.Файлы.Реквизиты.ВладелецФайла.Тип.СодержитТип(Тип(ИмяТипа)) Тогда
				МассивПереносимыхОМ.Добавить("Справочник."+Лев(ОМСправочник.Имя, СтрДлина(ОМСправочник.Имя)-19));
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого ИмяОМ Из МассивПереносимыхОМ Цикл
		ОМ = Метаданные.НайтиПоПолномуИмени(ИмяОМ);
		Элементы.ОбъектМетаданныхСФайлами.СписокВыбора.Добавить(ОМ.ПолноеИмя(), ОМ.Представление());
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбъектМетаданныхСФайламиПриИзменении(Элемент)
	
	ЗаполнитьТаблицуСсылок();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТаблицуСсылок()
	
	ТаблицаСсылок.Очистить();
	ТаблицаСсылокЗначение = РеквизитФормыВЗначение("ТаблицаСсылок");
	МассивСсылок = ПрисоединенныеФайлы.СсылкиНаОбъектыСФайлами(ОбъектМетаданныхСФайлами);
	Для Каждого Ссылка Из МассивСсылок Цикл
		НоваяСтрока = ТаблицаСсылокЗначение.Добавить();
		НоваяСтрока.Ссылка = Ссылка;
	КонецЦикла;
	ЗначениеВРеквизитФормы(ТаблицаСсылокЗначение, "ТаблицаСсылок");
	
КонецПроцедуры

&НаКлиенте
Процедура ПеренестиФайлы(Команда)
	
	Если ПустаяСтрока(ОбъектМетаданныхСФайлами) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			НСтр("ru = 'Укажите объект метаданных с файлами.'"), ,
			"ОбъектМетаданныхСФайлами");
		Возврат;
	КонецЕсли;
	
	ПеренестиФайлыСервер();
	ПоказатьПредупреждение(, НСтр("ru = 'Файлы успешно перенесены!'"));
	
КонецПроцедуры

&НаСервере
Процедура ПеренестиФайлыСервер()
	
	// Переносим файлы из справочника "Демо: Номенклатура"
	Для Каждого Строка Из ТаблицаСсылок Цикл
		ПрисоединенныеФайлы.СконвертироватьФайлыВПрисоединенные(Строка.Ссылка);
	КонецЦикла;
	
КонецПроцедуры
