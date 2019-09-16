#include <assert.h>
#include <stdio.h>
#include "rocksdb/db.h"

int main()
{
    rocksdb::DB* db;
    rocksdb::Options options;
    options.create_if_missing = true;
    rocksdb::Status status = rocksdb::DB::Open(options, "/tmp/testdb", &db);
    assert(status.ok());
    std::string value;
    rocksdb::Status s = db->Get(rocksdb::ReadOptions(), "test1", &value);
    if (s.ok()) s = db->Put(rocksdb::WriteOptions(), "test1", value);
    if (s.ok()) s = db->Delete(rocksdb::WriteOptions(), "test1");

    delete db;
    
    printf("test");
}
