.class Lx/c$e;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lx/c$i;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lx/c;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "e"
.end annotation


# instance fields
.field a:Ljava/util/concurrent/ExecutorService;


# direct methods
.method constructor <init>()V
    .locals 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    invoke-static {}, Lw/a;->e()Lw/a;

    move-result-object v0

    invoke-virtual {v0}, Lw/a;->b()Ljava/util/concurrent/ExecutorService;

    move-result-object v0

    iput-object v0, p0, Lx/c$e;->a:Ljava/util/concurrent/ExecutorService;

    return-void
.end method


# virtual methods
.method public a(Lj0/c$d;)Lx/c$d;
    .locals 1

    invoke-virtual {p1}, Lj0/c$d;->a()Z

    move-result p1

    if-eqz p1, :cond_0

    new-instance p1, Lx/c$h;

    iget-object v0, p0, Lx/c$e;->a:Ljava/util/concurrent/ExecutorService;

    invoke-direct {p1, v0}, Lx/c$h;-><init>(Ljava/util/concurrent/ExecutorService;)V

    return-object p1

    :cond_0
    new-instance p1, Lx/c$c;

    iget-object v0, p0, Lx/c$e;->a:Ljava/util/concurrent/ExecutorService;

    invoke-direct {p1, v0}, Lx/c$c;-><init>(Ljava/util/concurrent/ExecutorService;)V

    return-object p1
.end method
