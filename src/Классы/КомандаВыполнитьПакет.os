///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Перем Лог;
Перем ИспользуемаяВерсияПлатформы;

// Интерфейсная процедура, выполняет регистрацию команды и настройку парсера командной строки
//   
// Параметры:
//   ИмяКоманды 	- Строка										- Имя регистрируемой команды
//   Парсер 		- ПарсерАргументовКоманднойСтроки (cmdline)		- Парсер командной строки
//
Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
	
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Последовательно выполняет команды по сценариям, заданным в файлах (json)");

	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, 
		"Сценарии",
		"Файлы JSON содержащие последовательность команд и значения параметров,
		|могут быть указаны несколько файлов разделенные "";""
		|(обработка файлов выполняется в порядке следования)");

    Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры //ЗарегистрироватьКоманду()

// Интерфейсная процедура, выполняет текущую команду
//   
// Параметры:
//   ПараметрыКоманды 	- Соответствие						- Соответствие параметров команды и их значений
//
// Возвращаемое значение:
//	Число - код возврата команды
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт
    
	ПутьКСценариям	= ПараметрыКоманды["Сценарии"];

	Сценарии = ЧтениеСценариев.ПрочитатьСценарии(ПутьКСценариям);

	ВозможныйРезультат = МенеджерКомандПриложения.РезультатыКоманд();
	
	Если Сценарии.Количество() = 0 Тогда
		Лог.Ошибка("Не указано ни одного файла сценария для обработки");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Попытка
		ВыполнитьСценарии(Сценарии);

		Возврат ВозможныйРезультат.Успех;
	Исключение
		Лог.Ошибка(ОписаниеОшибки());
		Возврат ВозможныйРезультат.ОшибкаВремениВыполнения;
	КонецПопытки;

КонецФункции

// Последовательно выполняет переданные сценарии
//   
// Параметры:
//   Сценарии				- Массив - Массив сценариев для выполнения
//
Процедура ВыполнитьСценарии(Сценарии)
	
	Для Каждого ТекСценарий Из Сценарии Цикл
		Лог.Информация("Выполняется сценарий ""%1""", ОбъединитьПути(ТекущийКаталог(), ТекСценарий.ПутьКФайлу));
		ВыполнитьСценарий(ТекСценарий.Сценарий);
	КонецЦикла;

КонецПроцедуры //ВыполнитьСценарии()

// Выполняет изменение версии подсистемы конфигурации в хранилище конфигурации
//   
// Параметры:
//   Сценарий					- Соответствие - Последовательность команд с параметрами для выполнения
//
Процедура ВыполнитьСценарий(Сценарий)
	
	ОбщиеПараметры = Сценарий["params"];

	Если НЕ (ТипЗнч(ОбщиеПараметры) = Тип("Структура")
		ИЛИ ТипЗнч(ОбщиеПараметры) = Тип("Соответствие")) Тогда
		ОбщиеПараметры = Новый Соответствие();
	Иначе
		Лог.Отладка("Прочитаны общие параметры");
	КонецЕсли;

	ШагиСценария = Сценарий["stages"];

	Если НЕ (ТипЗнч(ШагиСценария) = Тип("Структура")
		ИЛИ ТипЗнч(ШагиСценария) = Тип("Соответствие")) Тогда
		Лог.Ошибка("Не найдены шаги сценария");
		Возврат;
	КонецЕсли;

	Для Каждого ТекШаг Из ШагиСценария Цикл
		Лог.Информация("Выполняется шаг ""%1""", ТекШаг.Ключ);
		ВыполнитьШагСценария(ТекШаг.Значение, ОбщиеПараметры);
	КонецЦикла;
	
КонецПроцедуры //ВыполнитьСценарий()

// Выполняет изменение версии подсистемы конфигурации в хранилище конфигурации
//   
// Параметры:
//   Сценарий					- Соответствие - Последовательность команд с параметрами для выполнения
//
Процедура ВыполнитьШагСценария(Шаг, Знач ОбщиеПараметры)
	
	Параметры = Новый Соответствие();

	Для Каждого ТекПараметр Из ОбщиеПараметры Цикл
		Параметры.Вставить(ТекПараметр.Ключ, ТекПараметр.Значение);
	КонецЦикла;

	ПараметрыШага = Шаг["params"];

	Если НЕ (ТипЗнч(ПараметрыШага) = Тип("Структура")
		ИЛИ ТипЗнч(ПараметрыШага) = Тип("Соответствие")) Тогда
		ПараметрыШага = Новый Соответствие();
	Иначе
		Лог.Отладка("Прочитаны параметры шага");
	КонецЕсли;

	Для Каждого ТекПараметр Из ПараметрыШага Цикл
		Параметры.Вставить(ТекПараметр.Ключ, ТекПараметр.Значение);
	КонецЦикла;

	МенеджерКомандПриложения.ВыполнитьКоманду(Шаг["command"], Параметры);

КонецПроцедуры //ВыполнитьШагСценария()

Лог = Логирование.ПолучитьЛог("ktb.app.yadt");