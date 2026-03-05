.class final Lk1/f;
.super Lk1/a;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "<T:",
        "Ljava/lang/Object;",
        ">",
        "Lk1/a<",
        "TT;>;"
    }
.end annotation


# instance fields
.field private final a:La1/p;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "La1/p<",
            "Lk1/c<",
            "-TT;>;",
            "Ls0/d<",
            "-",
            "Lq0/q;",
            ">;",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>(La1/p;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "La1/p<",
            "-",
            "Lk1/c<",
            "-TT;>;-",
            "Ls0/d<",
            "-",
            "Lq0/q;",
            ">;+",
            "Ljava/lang/Object;",
            ">;)V"
        }
    .end annotation

    invoke-direct {p0}, Lk1/a;-><init>()V

    iput-object p1, p0, Lk1/f;->a:La1/p;

    return-void
.end method


# virtual methods
.method public b(Lk1/c;Ls0/d;)Ljava/lang/Object;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lk1/c<",
            "-TT;>;",
            "Ls0/d<",
            "-",
            "Lq0/q;",
            ">;)",
            "Ljava/lang/Object;"
        }
    .end annotation

    iget-object v0, p0, Lk1/f;->a:La1/p;

    invoke-interface {v0, p1, p2}, La1/p;->invoke(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    invoke-static {}, Lt0/b;->c()Ljava/lang/Object;

    move-result-object p2

    if-ne p1, p2, :cond_0

    return-object p1

    :cond_0
    sget-object p1, Lq0/q;->a:Lq0/q;

    return-object p1
.end method
