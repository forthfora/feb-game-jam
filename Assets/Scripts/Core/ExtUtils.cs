using System;

namespace GameJamProject
{
    public static class ExtUtils
    {
        /// <summary>
        /// Shifts all the elements of an array to the right.
        /// </summary>
        /// <param name="array">The array to be shifted.</param>
        /// <param name="amount">Number of indexes to shift the array.</param>
        public static void ShiftRight(this Array array, int amount = 1)
        {
            if (array.Length <= amount) 
            {
                Array.Clear(array, 0, array.Length);
                return;
            }

            Array.Copy(array, 0, array, amount, array.Length - amount);
            Array.Clear(array, 0, amount);
        }
    }
}