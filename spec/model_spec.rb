# encoding: utf-8

require File.dirname(__FILE__) + '/spec_helper'

describe Backup::Model do

  before do
    class Backup::Database::TestDatabase
      def initialize(&block); end
    end
    class Backup::Storage::TestStorage
      def initialize(&block); end
    end
    class Backup::Archive
      def initialize(name, &block); end
    end
    class Backup::Compressor::Gzip
      def initialize(&block); end
    end
    class Backup::Compressor::SevenZip
      def initialize(&block); end
    end
  end

  let(:model) { Backup::Model.new('mysql-s3', 'MySQL S3 Backup for MyApp') {} }

  it do
    Backup::Model.new('blah', 'blah') {}
    Backup::Model.extension.should == 'tar'
  end

  it do
    Backup::Model.new('blah', 'blah') {}
    Backup::Model.file.should == "#{ File.join(TMP_PATH, "#{ TIME }.#{ TRIGGER }.tar") }"
  end

  it do
    Backup::Model.new('blah', 'blah') {}
    File.basename(Backup::Model.file).should == "#{ TIME }.#{ TRIGGER }.tar"
  end

  it do
    Backup::Model.new('blah', 'blah') {}
    Backup::Model.tmp_path.should == File.join(TMP_PATH, TRIGGER)
  end

  it 'should create a new model with a trigger and label' do
    model = Backup::Model.new('mysql-s3', 'MySQL S3 Backup for MyApp') {}
    model.trigger.should == 'mysql-s3'
    model.label.should == 'MySQL S3 Backup for MyApp'
  end

  it 'should have the time logged in the object' do
    model = Backup::Model.new('mysql-s3', 'MySQL S3 Backup for MyApp') {}
    model.time.should == TIME
  end

  describe '#extension' do
    it 'should start out with just .tar before compression occurs' do
      Backup::Model.extension.should == 'tar'
    end
  end

  describe 'databases' do
    it 'should add the mysql adapter to the array of databases to invoke' do
      model = Backup::Model.new('mysql-s3', 'MySQL S3 Backup for MyApp') do
        database('TestDatabase')
      end

      model.databases.count.should == 1
    end

    it 'should add 2 mysql adapters to the array of adapters to invoke' do
      model = Backup::Model.new('mysql-s3', 'MySQL S3 Backup for MyApp') do
        database('TestDatabase')
        database('TestDatabase')
      end

      model.databases.count.should == 2
    end
  end

  describe 'storages' do
    it 'should add a storage to the array of storages to use' do
      model = Backup::Model.new('mysql-s3', 'MySQL S3 Backup for MyApp') do
        store_to('TestStorage')
      end

      model.storages.count.should == 1
    end

    it 'should add a storage to the array of storages to use' do
      model = Backup::Model.new('mysql-s3', 'MySQL S3 Backup for MyApp') do
        store_to('TestStorage')
        store_to('TestStorage')
      end

      model.storages.count.should == 2
    end
  end

  describe 'archives' do
    it 'should add an archive to the array of archives to use' do
      model = Backup::Model.new('mysql-s3', 'MySQL S3 Backup for MyApp') do
        archive('my_archive')
      end

      model.archives.count.should == 1
    end

    it 'should add a storage to the array of storages to use' do
      model = Backup::Model.new('mysql-s3', 'MySQL S3 Backup for MyApp') do
        archive('TestStorage')
        archive('TestStorage')
      end

      model.archives.count.should == 2
    end
  end

  describe '#compress_with' do
    it 'should add a compressor to the array of compressors to use' do
      model = Backup::Model.new('mysql-s3', 'MySQL S3 Backup for MyApp') do
        compress_with('Gzip')
      end

      model.compressors.count.should == 1
    end

    it 'should add a compressor to the array of compressors to use' do
      model = Backup::Model.new('mysql-s3', 'MySQL S3 Backup for MyApp') do
        compress_with('Gzip')
        compress_with('SevenZip')
      end

      model.compressors.count.should == 2
    end
  end

  describe '#package!' do
    it 'should package the folder' do
      model.expects(:utility).with(:tar).returns(:tar)
      model.expects(:run).with("tar -c '#{ File.join(TMP_PATH, TRIGGER) }' &> /dev/null > '#{ File.join( TMP_PATH, "#{ TIME }.#{ TRIGGER }.tar" ) }'")
      model.send(:package!)
    end
  end

  describe '#clean!' do
    it 'should remove the temporary files and folders that were created' do
      model.expects(:utility).with(:rm).returns(:rm)
      model.expects(:run).with("rm -rf '#{ File.join(TMP_PATH, TRIGGER) }' '#{ File.join(TMP_PATH, "#{ TIME }.#{ TRIGGER }.tar") }'")
      model.send(:clean!)
    end
  end

end
