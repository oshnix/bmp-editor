# Редактор БМП изображений. 
-На данный момент имеет следующие возможности:
-Считывание и запись в память изображения.
-Поворот изображения на 90 градусов влево, или вправо.
-Применение фильтра "сепия" с помощью SSE инструкций и сравнение времени работы с аналогичным кодом на С.
## Для запуска:
	-make
	-поместить картинку bmp без таблицы цветов в директорию res
	-запустить исполняемый файл main,
	-указать bmp картинку, относительно директории res,
	-после выполнения функции указать имя файла, в который вы хотите поместить результат (с расширением bmp)
