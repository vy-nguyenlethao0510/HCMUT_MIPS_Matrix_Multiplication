#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>

using namespace std;

class Matrix {
private:
    int ** mat;
    int height;
    int width;
    int count;
public:
    Matrix(int, int);
    ~Matrix();
    int getCount() {return count;}
    void readfile(string);
    Matrix* multiplication(Matrix*);
    void print();
    int numofDifference(Matrix*);
};

Matrix::Matrix(int h, int w) {
    height = h; width = w;
    count = h * w;
    mat = new int*[height];
    for (int i = 0; i < height; i++) {
        mat[i] = new int[width];
    }
}

Matrix::~Matrix() {
    for (int i = 0; i < height; i++) {
        delete[] mat[i];
    }
    delete mat;
}

void Matrix::readfile(string filename) {
    ifstream file;
    file.open(filename);
    if (file.is_open()) {
        while (!file.eof()) {
            for (int i = 0; i < height; i++) {
                for (int j = 0; j < width; j++) {
                    file >> mat[i][j];
                }
            }
        }
    }
}

Matrix* Matrix::multiplication(Matrix *factor) {
    Matrix* result = new Matrix(height, factor->width);
    for (int i = 0; i < height; i++)
        for (int j = 0; j < factor->width; ++j) {
            result->mat[i][j] = 0;
        }
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < factor->width; j++) {
            for (int k = 0; k < width; k++) {
                  result->mat[i][j] += mat[i][k] * factor->mat[k][j];
            }
        }
    }
    return result;
}

void Matrix::print() {
    for (int i = 0; i < height; ++i) {
        for (int j = 0; j < width; ++j) {
            cout << " " << mat[i][j];
            if (j == width - 1) cout << endl;
        }
    }
}

int Matrix::numofDifference(Matrix *another) {
    int result = 0;
    for (int i = 0; i < height; ++i) {
        for (int j = 0; j < width; ++j) {
            if (mat[i][j] != another->mat[i][j])
                result++;
        }
    }
    return result;
}

int main() {

    //TODO: Input number of rows & cols
    int hA, hB, wA, wB;
    cout << "Matrix A---------------------------\nEnter height of A: ";
    cin >> hA;
    cout << "Enter width of A: ";
    cin >> wA;

    cout << "\nMatrix B---------------------------\nEnter height of B: ";
    cin >> hB;
    if (hB != wA) {
        cout << "Input dimensions do not satisfy matrix multiplication condition!\n";
        return 0;
    }
    cout << "Enter width of B: ";
    cin >> wB;
    Matrix* A = new Matrix(hA, wA);
    Matrix* B = new Matrix(hB, wB);
    Matrix* result = new Matrix(hA, wB);

    //TODO: Read matrix from txt file
    A->readfile("A.txt");
    cout << "Matrix A =\n"; A->print();

    B->readfile("B.txt");
    cout << "Matrix B =\n"; B->print();

    result->readfile("result.txt");
    cout << "Matrix result =\n"; result->print();

    //TODO: Calculate <A>x<B>
    Matrix* golden_result = A->multiplication(B);
    cout << "Golden result =\n"; golden_result->print();

    //TODO: Calculate rate of difference
    int num = golden_result->numofDifference(result);
    double rate = (double) ((double)num / (double)golden_result->getCount());
    cout << "The rate of difference is " << setprecision(5) << rate * 100 << "%\n";
    return 0;
}
