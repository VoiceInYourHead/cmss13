// ============ БАЗОВЫЙ КЛАСС СЧЁТЧИКА ============
/obj/effect/fd_sword/status_counter
	name = "stacks"
	icon = 'code/modules/fd_sword/icons/ui.dmi'
	icon_state = "gold"
	maptext_x = 12
	maptext_y = -10
	pixel_y = -10
	mouse_opacity = FALSE
	layer = MOB_LAYER + 0.1

	var/mob/attached_mob

/obj/effect/fd_sword/status_counter/New(loc, number, mob/owner)
	. = ..()

	attached_mob = owner
	maptext = SPAN_LANGCHAT("[number]")

	// Регистрируем счётчик у моба
	if(owner && owner.status_counters)
		owner.status_counters += src
		owner.arrange_counters_in_line()

/obj/effect/fd_sword/status_counter/Destroy()
	if(attached_mob && attached_mob.status_counters)
		attached_mob.status_counters -= src
		attached_mob.arrange_counters_in_line()

	. = ..()

// ============ ПОДТИПЫ СЧЁТЧИКОВ ============
/obj/effect/fd_sword/status_counter/golden_coins
	name = "GOLD STACKS"

/obj/effect/fd_sword/status_counter/rejuv_coins
	name = "LIFE STACKS"
	icon_state = "rejuvs"

/obj/effect/fd_sword/status_counter/cold_stacks
	name = "COLD STACKS"
	icon_state = "cold"

/obj/effect/fd_sword/status_counter/time_stacks
	name = "TIME STACKS"
	icon_state = "time"

/obj/effect/fd_sword/status_counter/bleed_stacks
	name = "BLEED STACKS"
	icon_state = "bleed"

// ============ МОБ С СИСТЕМОЙ СЧЁТЧИКОВ ============
/mob
	// Переменные для хранения значений статусов
	var/collected_gold = 0
	var/circle_stacks = 0
	var/ice_stacks = 0
	var/time_fragments = 0
	var/bleed_stacks = 0

	// Система счётчиков
	var/list/status_counters = list()  // Все активные счётчики
	var/list/counter_cache = list()    // Кэш для переиспользования объектов

	// Настройки расположения
	var/max_counters_per_row = 3       // Максимум счётчиков в ряду
	var/horizontal_spacing = 20        // Расстояние по X между счётчиками
	var/vertical_spacing = 15          // Расстояние по Y между рядами
	var/base_y_offset = -10            // Базовое смещение по Y

// ============ УТИЛИТЫ ДЛЯ РАБОТЫ С ОВЕРЛЕЯМИ ============

/mob/proc/add_overlay_safe(overlay)
	// Безопасное добавление оверлея (проверяем дубликаты)
	if(!overlays)
		overlays = list()

	// Проверяем, нет ли уже такого оверлея
	for(var/entry in overlays)
		if(entry == overlay)
			return FALSE

	overlays += overlay
	return TRUE

/mob/proc/remove_overlay_safe(overlay)
	// Безопасное удаление оверлея
	if(!overlays)
		return FALSE

	overlays -= overlay
	return TRUE

/mob/proc/clear_status_overlays()
	// Удаляем только наши счётчики из оверлеев
	if(!overlays || !status_counters)
		return

	for(var/obj/effect/fd_sword/status_counter/SC in status_counters)
		overlays -= SC

// ============ ОСНОВНАЯ ФУНКЦИЯ ОБНОВЛЕНИЯ (адаптированная) ============
/mob/proc/update_srd_statuses()
	// Удаляем старые счётчики из оверлеев
	clear_status_overlays()

	// Очищаем список счётчиков (но не удаляем объекты - они в кэше)
	status_counters.Cut()

	// Создаём новые счётчики для активных статусов
	if(collected_gold > 0)
		create_status_counter(/obj/effect/fd_sword/status_counter/golden_coins, collected_gold)

	if(circle_stacks > 0)
		create_status_counter(/obj/effect/fd_sword/status_counter/rejuv_coins, circle_stacks)

	if(ice_stacks > 0)
		create_status_counter(/obj/effect/fd_sword/status_counter/cold_stacks, ice_stacks)

	if(time_fragments > 0)
		create_status_counter(/obj/effect/fd_sword/status_counter/time_stacks, time_fragments)

	if(bleed_stacks > 0)
		create_status_counter(/obj/effect/fd_sword/status_counter/bleed_stacks, bleed_stacks)

	// Добавляем все счётчики в оверлеи
	for(var/obj/effect/fd_sword/status_counter/SC in status_counters)
		add_overlay_safe(SC)

// ============ СОЗДАНИЕ СЧЁТЧИКА С КЭШИРОВАНИЕМ (исправленная) ============
/mob/proc/create_status_counter(counter_type, value)
	// Проверяем кэш
	var/obj/effect/fd_sword/status_counter/SC

	if(counter_cache[counter_type])
		// Берём из кэша
		SC = counter_cache[counter_type]
		SC.maptext = SPAN_LANGCHAT("[value]")
	else
		// Создаём новый
		SC = new counter_type(null, value, src)  // Не передаём loc в New, чтобы не появлялся в мире
		SC.loc = null  // На всякий случай
		counter_cache[counter_type] = SC

	// Добавляем в список активных
	status_counters += SC

	// Возвращаем созданный счётчик
	return SC

// ============ ДИНАМИЧЕСКОЕ РАСПОЛОЖЕНИЕ В ЛИНИЮ ============
/mob/proc/arrange_counters_in_line()
	if(!status_counters || !status_counters.len)
		return

	var/total_counters = length(status_counters)

	for(var/i in 1 to total_counters)
		var/obj/effect/fd_sword/status_counter/SC = status_counters[i]

		// Рассчитываем позицию в сетке
		var/row = round((i - 1) / max_counters_per_row)      // Номер ряда (0, 1, 2...)
		var/col = (i - 1) % max_counters_per_row             // Позиция в ряду (0, 1, 2)

		// Центрируем ряд
		var/counters_in_current_row = min(max_counters_per_row, total_counters - (row * max_counters_per_row))
		var/row_width = (counters_in_current_row - 1) * horizontal_spacing
		var/row_start_x = -row_width / 2

		// Устанавливаем позицию
		SC.pixel_x = row_start_x + (col * horizontal_spacing)
		SC.pixel_y = base_y_offset - (row * vertical_spacing)

		// Обновляем позицию текста
		SC.maptext_x = initial(SC.maptext_x) + SC.pixel_x
		SC.maptext_y = initial(SC.maptext_y) + SC.pixel_y

// ============ ДОПОЛНИТЕЛЬНЫЕ УТИЛИТЫ ============
/mob/proc/add_status_value(counter_type, value)
	switch(counter_type)
		if("gold")
			collected_gold += value
		if("rejuv")
			circle_stacks += value
		if("cold")
			ice_stacks += value
		if("bleed")
			bleed_stacks += value
		if("time")
			time_fragments += value

	update_srd_statuses()

/mob/proc/remove_status_value(counter_type, value)
	switch(counter_type)
		if("gold")
			collected_gold = max(0, collected_gold - value)
		if("rejuv")
			circle_stacks = max(0, circle_stacks - value)
		if("cold")
			ice_stacks = max(0, ice_stacks - value)
		if("bleed")
			bleed_stacks = max(0, bleed_stacks - value)
		if("time")
			time_fragments = max(0, time_fragments - value)

	update_srd_statuses()

/mob/proc/set_status_value(counter_type, value)
	switch(counter_type)
		if("gold")
			collected_gold = value
		if("rejuv")
			circle_stacks = value
		if("cold")
			ice_stacks = value
		if("bleed")
			bleed_stacks = value
		if("time")
			time_fragments = value

	update_srd_statuses()

/mob/proc/clear_all_statuses()
	collected_gold = 0
	circle_stacks = 0
	ice_stacks = 0
	bleed_stacks = 0
	time_fragments = 0

	update_srd_statuses()

// ============ ПРИМЕР ИСПОЛЬЗОВАНИЯ ============
/*
// Добавить 50 золота
mob.add_status_value("gold", 50)

// Установить 10 стеков холода
mob.set_status_value("cold", 10)

// Обновить отображение вручную
mob.update_srd_statuses()
*/
