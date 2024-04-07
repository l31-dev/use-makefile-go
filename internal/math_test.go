package internal

import "testing"

func TestAdd(t *testing.T) {
	tests := []struct {
		numbers []int
		sum     int
	}{
		{[]int{}, 0},
		{[]int{1}, 1},
		{[]int{1, 2, 3, 4, 5}, 15},
		{[]int{1, -2, 3, -4, 5}, 3},
	}

	for _, test := range tests {
		if sum := Add(test.numbers...); sum != test.sum {
			t.Errorf("expected %d, but got %d", test.sum, sum)
		}
	}
}
