package main

import (
	"fmt"
)

type MyStruct struct {
	Value int
}

type DirectionStruct struct {
	// "right", "down", "up", "left"
	// Init - "right"
	direction string

	// Boundaries
	// Индексы границ для каждого направления, чтобы указатель шел по спирали, а не до конца массива
	upBoundary    int
	downBoundary  int
	leftBoundary  int
	rightBoundary int
}

// Task 1: Ha ha, classic! ᕕ(ᐛ)ᕗ
// Поменять местами значеня двух переменных тремя или более способами!
func runTask1() {
	fmt.Println("\nTask1\n---")

	a, b := 1, 2
	fmt.Printf("Init:\t\t a = %d, b = %d", a, b)

	// 1 - classic swap
	c := a
	a = b
	b = c
	fmt.Printf("\nSwap:\t\t a = %d, b = %d", a, b)

	// 2 - вариант, допустимый в go: переприсваивание
	a, b = 1, 2
	a, b = b, a
	fmt.Printf("\nReAssign:\t a = %d, b = %d", a, b)

	// 3 - только для int: арифметикой
	a, b = 1, 2
	a = a + b
	b = a - b
	a = a - b
	fmt.Printf("\nMath:\t\t a = %d, b = %d", a, b)

	fmt.Print("\n---")

	// 4 - для string: через slices
	str1, str2 := "string1", "str2"
	fmt.Printf("\nInit str:\t str1 = %s, str2 = %s", str1, str2)

	str1 = str1 + str2
	str2 = str1[:len(str1)-len(str2)]
	str1 = str1[len(str2):]
	fmt.Printf("\nSlices Swap:\t str1 = %s, str2 = %s", str1, str2)

	fmt.Print("\n---")

	// 5 - swap objects через указатели
	obj1 := &MyStruct{Value: 1}
	obj2 := &MyStruct{Value: 2}
	fmt.Printf("\nInit:\t\t obj1 = %o, obj2 = %o", obj1, obj2)

	*obj1, *obj2 = *obj2, *obj1
	fmt.Printf("\nSwapObjets:\t obj1 = %o, obj2 = %o", obj1, obj2)
	fmt.Println()
}

// Task 2: Написать функцию,
// которая принимает на вход целое число n > 0,
// создает двумерный массив размера n x n
// и последовательно заполняет его 1, 2, ... , n^2 по спирали по часовой стрелке,
// начиная с первого элемента массива. Например, для n = 4 результат должен быть таким:
/*
	1	2	3	4
	12	13	14	5
	11	16	15	6
	10	9	8	7
*/
func runTask2(n int) {
	fmt.Println("\nTask2\n---")
	fmt.Printf("n = %d", n)
	fmt.Println("\nOutput:")

	// Make
	arr := make([][]int, n)
	for i := range arr {
		arr[i] = make([]int, n)
	}

	// Fill
	// Стартовая точка - левый верхний угол
	// Из-за особенностей алгоритма и движения по спирали, необходимо сначала прибавить индекс (см. ниже)
	// Поэтому начинаем за массивом (j = -1)
	i := 0
	j := -1

	directionObj := DirectionStruct{
		direction: "right",

		// Инициализируются в зависимости от движения
		// Алгоритм следующий: при каждом изменении направления, соответствющая граница либо уменьшается на 1
		// либо увеличивается на 1, в зависимости от направления движения
		rightBoundary: n,
		downBoundary:  n,
		leftBoundary:  0,
		// До верхней сразу не должно доходить, если мы идем по спирали вправо
		upBoundary: 1,
	}

	for val := 1; val <= n*n; val++ {
		switch directionObj.direction {
		case "right":
			if j < directionObj.rightBoundary-1 {
				// step right
				j++
				arr[i][j] = val
			} else {
				// step down
				i++
				directionObj.rightBoundary--
				directionObj.direction = "down"
				arr[i][j] = val
			}
		case "down":
			if i < directionObj.downBoundary-1 {
				// step down
				i++
				arr[i][j] = val
			} else {
				// step left
				j--
				directionObj.downBoundary--
				directionObj.direction = "left"
				arr[i][j] = val
			}
		case "left":
			if j > directionObj.leftBoundary {
				// step left
				j--
				arr[i][j] = val
			} else {
				// step up
				i--
				directionObj.leftBoundary++
				directionObj.direction = "up"
				arr[i][j] = val
			}
		case "up":
			if i > directionObj.upBoundary {
				// step up
				i--
				arr[i][j] = val
			} else {
				// step right
				j++
				directionObj.upBoundary++
				directionObj.direction = "right"
				arr[i][j] = val
			}
		default:
			fmt.Print("Unreachable Err!")
			return
		}
	}

	// Print
	for i := range arr {
		for j := range arr[i] {
			fmt.Printf("%d\t", arr[i][j])
		}
		fmt.Print("\n")
	}
}
