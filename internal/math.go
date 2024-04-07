package internal

func Add(nbs ...int) int {
	sum := 0

	for _, nb := range nbs {
		sum += nb
	}

	return sum
}
