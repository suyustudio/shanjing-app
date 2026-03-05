.class public final Ls0/e$b;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ls0/g$c;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Ls0/e;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "b"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Ls0/g$c<",
        "Ls0/e;",
        ">;"
    }
.end annotation


# static fields
.field static final synthetic d:Ls0/e$b;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    new-instance v0, Ls0/e$b;

    invoke-direct {v0}, Ls0/e$b;-><init>()V

    sput-object v0, Ls0/e$b;->d:Ls0/e$b;

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method
