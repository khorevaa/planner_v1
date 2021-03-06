﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

// Для подсистемы "Варианты отчетов" при работе в модели сервиса.
Функция ВариантыНастроек() Экспорт
	Результат = Новый Массив;
	Результат.Добавить(Новый Структура("Имя, Представление", "Основной", НСтр("ru = 'Демо: Динамика изменений файлов'")));
	Возврат Результат;
КонецФункции

// Настройки размещения в панели отчетов.
//
// Параметры:
//   Настройки - Коллекция - Используется для описания настроек отчетов и вариантов
//       см. описание к ВариантыОтчетов.ДеревоНастроекВариантовОтчетовКонфигурации()
//   НастройкиОтчета - СтрокаДереваЗначений - Настройки размещения всех вариантов отчета.
//       см. "Реквизиты для изменения" функции ВариантыОтчетов.ДеревоНастроекВариантовОтчетовКонфигурации().
//
// Описание:
//   См. ВариантыОтчетовПереопределяемый.НастроитьВариантыОтчетов().
//
// Вспомогательные методы:
//   НастройкиВарианта = ВариантыОтчетов.ОписаниеВарианта(Настройки, НастройкиОтчета, "<ИмяВарианта>");
//   ВариантыОтчетов.УстановитьРежимВыводаВПанеляхОтчетов(Настройки, НастройкиОтчета, Истина/Ложь); // Отчет поддерживает только этот режим.
//
Процедура НастроитьВариантыОтчета(Настройки, НастройкиОтчета) Экспорт
	ВариантыОтчетов.УстановитьРежимВыводаВПанеляхОтчетов(Настройки, НастройкиОтчета, Ложь); // Отчет поддерживает только этот режим.
	НастройкиОтчета.ОпределитьНастройкиФормы = Истина;
	
	НастройкиВарианта = ВариантыОтчетов.ОписаниеВарианта(Настройки, НастройкиОтчета, "Основной");
	НастройкиВарианта.Описание = НСтр("ru = 'Динамика изменений файлов в виде графика.'");
	НастройкиВарианта.ФункциональныеОпции.Добавить("ХранитьФайлыВТомахНаДиске");
	НастройкиВарианта.Размещение.Вставить(Метаданные.Подсистемы._ДемоОрганайзер.Подсистемы._ДемоРаботаСФайлами, "Важный");
КонецПроцедуры

#КонецЕсли