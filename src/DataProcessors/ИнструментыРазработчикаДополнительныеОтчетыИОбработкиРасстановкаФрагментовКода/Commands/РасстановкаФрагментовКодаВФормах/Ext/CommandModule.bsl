﻿////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	ОткрытьФорму(
		"Обработка.ИнструментыРазработчикаДополнительныеОтчетыИОбработкиРасстановкаФрагментовКода.Форма",
		Новый Структура,
		ПараметрыВыполненияКоманды.Источник,
		ПараметрыВыполненияКоманды.Уникальность);
КонецПроцедуры
